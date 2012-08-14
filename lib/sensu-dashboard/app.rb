require 'sensu/config'
require 'em-http-request'
require 'em-websocket'
require 'sinatra/async'
require 'slim'
require 'sass'

class Dashboard < Sinatra::Base
  register Sinatra::Async

  def self.run(options={})
    EM::run do
      self.setup(options)
      self.websocket_server
      self.run!(:port => $settings.dashboard.port)

      %w[INT TERM].each do |signal|
        Signal.trap(signal) do
          self.stop(signal)
        end
      end
    end
  end

  def self.setup(options={})
    config = Sensu::Config.new(options)
    $settings = config.settings
    $logger = config.logger || config.open_log
    unless $settings.key?('dashboard')
      raise config.invalid_config('missing the following key: dashboard')
    end
    unless $settings.dashboard.port.is_a?(Integer)
      raise config.invalid_config('dashboard must have a port')
    end
    unless $settings.dashboard.user.is_a?(String) && $settings.dashboard.password.is_a?(String)
      raise config.invalid_config('dashboard must have a user and password')
    end
    if options[:daemonize]
      Process.daemonize
    end
    if options[:pid_file]
      Process.write_pid(options[:pid_file])
    end
    $api_server = 'http://' + $settings.api.host + ':' + $settings.api.port.to_s
  end

  def self.websocket_server
    $websocket_connections = []
    EM::WebSocket.start(:host => '0.0.0.0', :port => 9000) do |websocket|
      websocket.onopen do
        $logger.info('[websocket] -- client connected to websocket')
        $websocket_connections.push(websocket)
      end
      websocket.onclose do
        $logger.info('[websocket] -- client disconnected from websocket')
        $websocket_connections.delete(websocket)
      end
    end
  end

  set :root, File.dirname(__FILE__)
  set :static, true
  set :public_folder, Proc.new { File.join(root, 'public') }
  set :haml, { :format => :html5 }

  use Rack::Auth::Basic do |user, password|
    user == $settings.dashboard.user && password == $settings.dashboard.password
  end

  before do
    content_type 'text/html'
  end

  aget '/', :provides => 'html' do
    body slim :events
  end

  aget '/js/templates/*.tmpl' do |template|
    body slim template.to_sym, :layout => false
  end

  aget '/css/*.css' do |stylesheet|
    content_type 'text/css'
    body sass stylesheet.to_sym
  end

  apost '/' do
    content_type 'application/json'
    $logger.debug('[events] -- ' + request.ip + ' -- POST -- triggering dashboard refresh')
    unless $websocket_connections.empty?
      $websocket_connections.each do |websocket|
        websocket.send '{"update":"true"}'
      end
    end
    body '{"success":"triggered dashboard refresh"}'
  end

  #
  # API Proxy
  #
  aget '/*', :provides => 'json' do |path|
    content_type 'application/json'
    begin
      http = EM::HttpRequest.new($api_server + '/' + path).get :head => {'Accept' => 'application/json'}
    rescue => e
      $logger.warning(e)
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

  def self.stop(signal)
    $logger.warn('[stop] -- stopping sensu dashboard -- ' + signal)
    EM::Timer.new(1) do
      EM::stop_event_loop
    end
  end
end

options = Sensu::Config.read_arguments(ARGV)
Dashboard.run(options)
