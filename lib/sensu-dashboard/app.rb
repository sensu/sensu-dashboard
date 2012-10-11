require 'sensu/base'
require 'thin'
require 'sinatra/async'
require 'em-http-request'
require 'slim'
require 'sass'

module Sensu
  class Dashboard < Sinatra::Base
    register Sinatra::Async

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
        $logger = Sensu::Logger.get
        base = Sensu::Base.new(options)
        $settings = base.settings
        unless $settings[:dashboard].is_a?(Hash)
          invalid_settings('missing dashboard configuration')
        end
        unless $settings[:dashboard][:port].is_a?(Integer)
          invalid_settings('dashboard must have a port', {
            :dashboard => $settings[:dashboard]
          })
        end
        unless $settings[:dashboard][:user].is_a?(String) && $settings[:dashboard][:password].is_a?(String)
          invalid_settings('dashboard must have a user and password', {
            :dashboard => $settings[:dashboard]
          })
        end
        $api_url = 'http://' + $settings[:api][:host] + ':' + $settings[:api][:port].to_s
        $api_options = {}
        if $settings[:api][:user] && $settings[:api][:password]
          $api_options.merge!(:head => {:authorization => [$settings[:api][:user], $settings[:api][:password]]})
        end
      end

      def start
        Thin::Logging.silent = true
        Thin::Server.start(self, $settings[:dashboard][:port])
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

    def request_log(env)
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

    use Rack::Auth::Basic do |user, password|
      user == $settings[:dashboard][:user] && password == $settings[:dashboard][:password]
    end

    before do
      content_type 'text/html'
      request_log(env)
    end

    aget '/', :provides => 'html' do
      body slim :main
    end

    aget '/js/templates/*.tmpl' do |template|
      body slim "templates/#{template}".to_sym, :layout => false
    end

    aget '/css/*.css' do |stylesheet|
      content_type 'text/css'
      body sass stylesheet.to_sym
    end

    #
    # API Proxy
    #
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
  end
end
