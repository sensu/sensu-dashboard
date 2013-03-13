require 'sensu/base'
require 'thin'
require 'sinatra/async'
require 'em-http-request'
require 'slim'
require 'sass'
require 'uri'
require 'sprockets'
require 'yui/compressor'
require 'handlebars_assets'

require File.dirname(__FILE__) + '/constants.rb'

module Sensu::Dashboard
  class Server < Sinatra::Base
    register Sinatra::Async

    configure do
      set :assets, (Sprockets::Environment.new { |env|
          env.append_path(settings.root + "/assets/javascripts")
          env.append_path(settings.root + "/assets/stylesheets")
          env.append_path HandlebarsAssets.path
          if ENV['RACK_ENV'] == 'production'
            env.js_compressor  = YUI::JavaScriptCompressor.new
            env.css_compressor = YUI::CssCompressor.new
          end
        })
    end

    class << self
      def run(options={})
        EM::run do
          setup(options)
          start
          trap_signals
        end
      end

      def invalid_settings(reason, details={})
        $logger.fatal('invalid settings', {
          :reason => reason
        }.merge(details))
        $logger.fatal('SENSU DASHBOARD NOT RUNNING!')
        exit 2
      end

      def setup(options={})
        base = Sensu::Base.new(options)
        $logger = base.logger
        settings = base.settings
        $dashboard_settings = settings[:dashboard] || {
          :port => 8080
        }
        $api_settings = settings[:api] || {
          :host => 'localhost',
          :port => 4567,
          :user => nil,
          :password => nil
        }
        unless $dashboard_settings.is_a?(Hash)
          invalid_settings('misconfigured dashboard configuration')
        end
        unless $dashboard_settings[:port].is_a?(Integer)
          invalid_settings('dashboard port must be an integer', {
            :settings => $dashboard_settings
          })
        end
        base.setup_process
        $api_url = 'http://' + $api_settings[:host] + ':' + $api_settings[:port].to_s
        $api_options = {:head => {}}
        if $api_settings[:user] && $api_settings[:password]
          $api_options.merge!(:head => {:authorization => [$api_settings[:user], $api_settings[:password]]})
        end
      end

      def start
        Thin::Logging.silent = true
        bind = $dashboard_settings[:bind] || '0.0.0.0'
        Thin::Server.start(bind, $dashboard_settings[:port], self)
      end

      def stop
        $logger.warn('stopping')
        EM::stop_event_loop
      end

      def trap_signals
        %w[INT TERM].each do |signal|
          Signal.trap(signal) do
            $logger.warn('received signal', {
              :signal => signal
            })
            stop
          end
        end
      end
    end

    def request_log_line
      $logger.info([env['REQUEST_METHOD'], env['REQUEST_PATH']].join(' '), {
        :remote_address => env['REMOTE_ADDR'],
        :user_agent => env['HTTP_USER_AGENT'],
        :request_method => env['REQUEST_METHOD'],
        :request_uri => env['REQUEST_URI'],
        :request_body =>  env['rack.input'].read
      })
      env['rack.input'].rewind
    end

    set :root, File.dirname(__FILE__)
    set :static, true
    set :public_folder, Proc.new { File.join(root, 'public') }

    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm='Restricted Area')
          throw(:halt, [401, 'Not authorized\n'])
        end
      end

      def authorized?
        return true if [$dashboard_settings[:user], $dashboard_settings[:password]].all? { |param| param.nil? }
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$dashboard_settings[:user], $dashboard_settings[:password]]
      end
    end

    before do
      content_type 'text/html'
      request_log_line
      protected!
    end

    aget '/', :provides => 'html' do
      body slim :main
    end

    aget '/assets/app.js' do
      content_type 'application/javascript'
      body settings.assets['app.js']
    end

    aget '/assets/app.css' do
      content_type 'text/css'
      body settings.assets['app.css']
    end

    aget '/js/templates/*.tmpl' do |template|
      body slim "templates/#{template}".to_sym, :layout => false
    end

    aget '/css/*.css' do |stylesheet|
      content_type 'text/css'
      body sass stylesheet.to_sym
    end

    aget '/health', :provides => 'json' do
      content_type 'application/json'
      begin
        $api_options[:head]['Accept'] = 'application/json'
        http = EM::HttpRequest.new($api_url + '/info').get($api_options)
      rescue => error
        $logger.error('failed to query sensu /info api', {
          :error => error
        })
        status 404
        body '{"error":"could not retrieve /info from the sensu api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve /info from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        health = Oj.load(http.response)
        health[:sensu_dashboard] = {:version => Sensu::Dashboard::VERSION}
        body Oj.dump(health)
      end
    end

    #
    # API Proxy
    #
    aget '/all', :provides => 'json' do
      content_type 'application/json'
      begin
        $api_options[:head]['Accept'] = 'application/json'
        multi = EM::MultiRequest.new
        multi.add :events, EM::HttpRequest.new($api_url + '/events').get($api_options)
        multi.add :checks, EM::HttpRequest.new($api_url + '/checks').get($api_options)
        multi.add :clients, EM::HttpRequest.new($api_url + '/clients').get($api_options)
        multi.add :stashes, EM::HttpRequest.new($api_url + '/stashes').get($api_options)
        multi.add :health, EM::HttpRequest.new($api_url + '/info').get($api_options)
      rescue => error
        $logger.error('failed to query the sensu api', {
          :error => error
        })
        status 404
        body '{"error":"could not retrieve /events, /clients, /checks, /info and/or /stashes from the sensu api"}'
      end

      multi.callback do
        unless multi.responses[:errback].keys.count > 0
          response = {
            :events  => Oj.load(multi.responses[:callback][:events].response),
            :checks  => Oj.load(multi.responses[:callback][:checks].response),
            :clients => Oj.load(multi.responses[:callback][:clients].response),
            :health  => Oj.load(multi.responses[:callback][:health].response)
          }
          response[:health][:sensu_dashboard] = {:version => Sensu::Dashboard::VERSION}
          begin
            $api_options[:head]['Accept'] = 'application/json'
            $api_options[:body] = multi.responses[:callback][:stashes].response
            http = EM::HttpRequest.new($api_url + '/stashes').post($api_options)
          rescue => error
            $logger.error('failed to query the sensu api', {
              :error => error
            })
            status 404
            body '{"error":"could not retrieve /stashes from the sensu api"}'
          end

          http.errback do
            status 404
            body '{"error":"could not retrieve /stashes from the sensu api"}'
          end

          http.callback do
            stashes = {}
            stashes = Oj.load(http.response).map do |path, keys|
              { :path => path, :keys => keys }
            end unless http.response.empty?
            response[:stashes] = stashes
            status 200
            body Oj.dump(response)
          end
        else
          $logger.error('sensu api returned an error', {
            :error => multi.responses[:errback]
          })
          status 500
          body '{"error":"sensu api returned an error while retrieving /events, /clients, /checks, /info, and/or /stashes from the sensu api"}'
        end
      end
    end

    aget '/*', :provides => 'json' do |path|
      content_type 'application/json'
      begin
        $api_options[:head]['Accept'] = 'application/json'
        http = EM::HttpRequest.new($api_url + '/' + path).get($api_options)
      rescue => error
        $logger.error('failed to query the sensu api', {
          :error => error
        })
        status 404
        body '{"error":"could not retrieve /'+path+' from the sensu api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve /'+path+' from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        body http.response
      end
    end

    apost '/*', :provides => 'json' do |path|
      content_type 'application/json'
      begin
        $api_options[:head]['Accept'] = 'application/json'
        $api_options[:body] = request.body.read
        http = EM::HttpRequest.new($api_url + '/' + path).post($api_options)
      rescue => error
        $logger.error('failed to query the sensu api', {
          :error => error
        })
        status 404
        body '{"error":"could not retrieve /'+path+' from the sensu api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve /'+path+' from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        body http.response
      end
    end

    aput '/*', :provides => 'json' do |path|
      content_type 'application/json'
      begin
        $api_options[:head]['Accept'] = 'application/json'
        $api_options[:body] = request.body.read
        http = EM::HttpRequest.new($api_url + '/' + path).post($api_options)
      rescue => error
        $logger.error('failed to query the sensu api', {
          :error => error
        })
        status 404
        body '{"error":"could not retrieve /'+path+' from the sensu api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve /'+path+' from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        body http.response
      end
    end

    adelete '/*', :provides => 'json' do |path|
      content_type 'application/json'
      begin
        $api_options[:head]['Accept'] = 'application/json'
        http = EM::HttpRequest.new($api_url + '/' + path).delete($api_options)
      rescue => error
        $logger.error('failed to query the sensu api', {
          :error => error
        })
        status 404
        body '{"error":"could not delete /'+path+' from the sensu api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not delete /'+path+' from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        body http.response
      end
    end
  end
end
