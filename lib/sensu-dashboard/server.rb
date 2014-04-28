gem 'thin', '1.5.0'
gem 'sinatra', '1.3.5'
gem 'async_sinatra', '1.0.0'

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
        setup(options)
        EM::run do
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
        if settings[:dashboard]
          unless settings[:dashboard].is_a?(Hash)
            invalid_settings('dashboard must be a hash')
          end
        end
        $dashboard_settings = settings[:dashboard] || Hash.new
        $dashboard_settings[:port] ||= 8080
        $dashboard_settings[:poll_frequency] ||= 10
        $api_settings = $dashboard_settings[:api] || settings[:api] || Hash.new
        $api_settings[:host] ||= 'localhost'
        $api_settings[:port] ||= 4567
        unless $dashboard_settings[:port].is_a?(Integer)
          invalid_settings('dashboard port must be an integer', {
            :settings => $dashboard_settings
          })
        end
        unless $dashboard_settings[:poll_frequency].is_a?(Integer)
          invalid_settings('dashboard poll frequency must be an integer', {
            :settings => $dashboard_settings
          })
        end
        $api_url = 'http://' + $api_settings[:host] + ':' + $api_settings[:port].to_s
        $api_options = {:head => {'Accept' => 'application/json'}}
        if $api_settings[:user] && $api_settings[:password]
          $api_options.merge!(:head => {:authorization => [$api_settings[:user], $api_settings[:password]]})
        end
        base.setup_process
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
        $signals = Array.new
        Sensu::STOP_SIGNALS.each do |signal|
          Signal.trap(signal) do
            $signals << signal
          end
        end
        EM::PeriodicTimer.new(1) do
          signal = $signals.shift
          if Sensu::STOP_SIGNALS.include?(signal)
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
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
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

    aget '/info', :provides => 'json' do
      content_type 'application/json'

      http = EM::HttpRequest.new($api_url + '/info').get($api_options)

      http.errback do
        status 502
        body '{"error":"could not retrieve /info from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        info = Oj.load(http.response)
        info[:sensu_dashboard] = {
          :version => Sensu::Dashboard::VERSION,
          :poll_frequency => $dashboard_settings[:poll_frequency]
        }
        body Oj.dump(info)
      end
    end

    #
    # API Proxy
    #
    aget '/all', :provides => 'json' do
      content_type 'application/json'

      routes = [:events, :checks, :clients, :stashes, :info]

      multi = EM::MultiRequest.new

      routes.each do |route|
        multi.add route, EM::HttpRequest.new($api_url + '/' + route.to_s).get($api_options)
      end

      multi.callback do
        empty_body = routes.detect do |route|
          if multi.responses[:callback][route]
            multi.responses[:callback][route].response == ""
          end
        end

        unless multi.responses[:errback].keys.count > 0 || empty_body
          response = Hash.new

          routes.each do |route|
            response[route] = Oj.load(multi.responses[:callback][route].response)
          end

          response[:info][:sensu_dashboard] = {
            :version => Sensu::Dashboard::VERSION,
            :poll_frequency => $dashboard_settings[:poll_frequency]
          }

          status 200
          body Oj.dump(response)
        else
          failed_requests = []
          multi.responses[:errback].each do |route, _|
            failed_requests << '/' + route.to_s
          end
          if empty_body
            failed_requests << empty_body
          end
          error_details = {:error => 'could not retrieve ' + failed_requests.join(', ') + ' from the sensu api'}
          $logger.error('failed to query the sensu api', error_details)
          status 502
          body Oj.dump(error_details)
        end
      end
    end

    aget '/*', :provides => 'json' do |path|
      content_type 'application/json'
      begin
        http = EM::HttpRequest.new($api_url + '/' + path).get($api_options)
      rescue => error
        $logger.error('failed to query the sensu api', {
          :error => error
        })
        status 404
        body '{"error":"could not retrieve /'+path+' from the sensu api"}'
      end

      http.errback do
        status 502
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
        status 502
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
        status 502
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
        http = EM::HttpRequest.new($api_url + '/' + path).delete($api_options)
      rescue => error
        $logger.error('failed to query the sensu api', {
          :error => error
        })
        status 404
        body '{"error":"could not delete /'+path+' from the sensu api"}'
      end

      http.errback do
        status 502
        body '{"error":"could not delete /'+path+' from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        body http.response
      end
    end
  end
end
