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

  aget '/' do
    redirect '/events'
  end

  aget '/events', :provides => 'html' do
    @path = request.path_info
#    @js = erb :event_templates, :layout => false
    body slim :events
  end

  aget '/clients' do
    @path = request.path_info
#    @js = erb :client_templates
    body erb :clients
  end
  
  aget '/stashes' do
    @path = request.path_info
#    @js = erb :stash_templates
    body erb :stashes
  end

  aget '/css/main.css' do
    content_type 'text/css'
    body sass :main
  end
  
  apost '/events' do
    content_type 'application/json'
    $logger.debug('[events] -- ' + request.ip + ' -- POST -- triggering dashboard refresh')
    unless $websocket_connections.empty?
      $websocket_connections.each do |websocket|
        websocket.send '{"update":"true"}'
      end
    end
    body '{"success":"triggered dashboard refresh"}'
  end

  aget '/events/autocomplete' do
    content_type 'application/json'
    multi = EM::MultiRequest.new

    requests = [
      $api_server + '/events',
      $api_server + '/clients'
    ]

    requests.each do |url|
      multi.add EM::HttpRequest.new(url).get
    end

    multi.callback do
      events = {}
      clients = []

      multi.responses[:succeeded].each do |request|
        body = JSON.parse(request.response)
        case body
        when Hash
          events = body
        when Array
          clients = body
        end
      end

      if events && clients
        autocomplete = []
        statuses = {:warning => [], :critical => [], :unknown => []}
        subscriptions = {}
        checks = []

        # searching by client
        clients.each do |client|
          client_name = client['name']
          if events.include?(client_name)
            autocomplete.push({:value => [client_name], :type => 'client', :name => client_name})
            client['subscriptions'].each do |subscription|
              subscriptions[subscription] ||= []
              subscriptions[subscription].push(client_name)
            end
            events[client_name].each do |check, event|
              case event['status']
              when 1
                statuses[:warning].push(event['status'])
              when 2
                statuses[:critical].push(event['status'])
              else
                statuses[:unknown].push(event['status'])
              end
              checks.push(check)
            end
          end
        end

        # searching by subscription
        subscriptions.each do |k, v|
          autocomplete.push({:value => v.uniq, :type => 'subscription', :name => k})
        end

        # searching by status
        statuses.each do |k, v|
          autocomplete.push({:value => v.uniq, :type => 'status', :name => k})
        end

        # searching by check
        checks.uniq.each do |v|
          autocomplete.push({:value => [v], :type => 'check', :name => v})
        end

        body autocomplete.to_json
      else
        status 404
        body '{"error":"could not retrieve events and/or clients from the sensu api"}'
      end
    end
  end

  aget '/clients/autocomplete' do
    content_type 'application/json'
    multi = EM::MultiRequest.new

    requests = [
     $api_server + '/clients'
    ]

    requests.each do |url|
      multi.add EM::HttpRequest.new(url).get
    end

    multi.callback do
      events = {}
      clients = []

      multi.responses[:succeeded].each do |request|
        body = JSON.parse(request.response)
        case body
        when Array
          clients = body
        end
      end

      if clients
        autocomplete = []
        subscriptions = {}

        # searching by client
        clients.each do |client|
          client_name = client['name']
          autocomplete.push({:value => [client_name], :type => 'client', :name => client_name})
          client['subscriptions'].each do |subscription|
            subscriptions[subscription] ||= []
            subscriptions[subscription].push(client_name)
          end
        end

        # searching by subscription
        subscriptions.each do |k, v|
          autocomplete.push({:value => v.uniq, :type => 'subscription', :name => k})
        end

        body autocomplete.to_json
      else
        status 404
        body '{"error":"could not retrieve clients from the sensu api"}'
      end
    end
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
