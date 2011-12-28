require 'sensu/config'
require 'em-http-request'
require 'em-websocket'
require 'sinatra/async'
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
    EM::WebSocket.start(:host => "0.0.0.0", :port => 9000) do |websocket|
      websocket.onopen do
        $websocket_connections.push(websocket)
        $logger.info('[websocket] -- client connected to websocket')
      end
      websocket.onclose do
        $websocket_connections.delete websocket
        $logger.info('[websocket] -- client disconnected from websocket')
      end
    end
  end

  set :root, File.dirname(__FILE__)
  set :static, true
  set :public_folder, Proc.new { File.join(root, "public") }

  use Rack::Auth::Basic do |user, password|
    user == $settings.dashboard.user && password == $settings.dashboard.password
  end

  before do
    content_type 'application/json'
  end

  aget '/' do
    content_type 'text/html'
    @js = erb :event_templates, :layout => false
    body erb :index
  end

  aget '/clients' do
    content_type 'text/html'
    @js = erb :client_templates, :layout => false
    body erb :clients
  end

  aget '/stashes' do
    content_type 'text/html'
    @js = erb :stash_templates, :layout => false
    body erb :stashes
  end

  aget '/css/sonian.css' do
    content_type 'text/css'
    body sass :sonian
  end

  apost '/events.json' do
    $logger.debug('[events] -- ' + request.ip + ' -- POST -- triggering dashboard refreshes with websocket')
    unless $websocket_connections.empty?
      $websocket_connections.each do |websocket|
        websocket.send '{"update":"true"}'
      end
    end
    body '{"success":"triggered dashboard refresh"}'
  end

  aget '/autocomplete.json' do
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

  aget '/clients/autocomplete.json' do
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

  aget '/events.json' do
    begin
      http = EM::HttpRequest.new($api_server + '/events').get
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not retrieve events from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve events from the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  aget '/clients.json' do
    begin
      http = EM::HttpRequest.new($api_server + '/clients').get
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not retrieve clients from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve clients from the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  aget '/client/:id.json' do |id|
    begin
      http = EM::HttpRequest.new($api_server + '/client/' + id).get
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not retrieve client from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve client from the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  adelete '/client/:id.json' do |id|
    begin
      http = EventMachine::HttpRequest.new($api_server + '/client/' + id).delete
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not delete client from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not delete client from the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  aget '/stash/*.json' do |path|
    begin
      http = EM::HttpRequest.new($api_server + '/stash/' + path).get
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not retrieve a stash from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve a stash from the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  apost '/stash/*.json' do |path|
    begin
      request_options = {
        :body => {'timestamp' => Time.now.to_i}.to_json,
        :head => {
          'content-type' => 'application/json'
        }
      }
      http = EM::HttpRequest.new($api_server + '/stash/' + path).post request_options
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not create a stash with the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not create a stash with the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  adelete '/stash/*.json' do |path|
    begin
      http = EM::HttpRequest.new($api_server + '/stash/' + path).delete
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not delete a stash with the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not delete a stash with the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  apost '/event/resolve.json' do
    begin
      request_options = {
        :body => request.body.read,
        :head => {
          'content-type' => 'application/json'
        }
      }
      http = EM::HttpRequest.new($api_server + '/event/resolve').post request_options
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not resolve an event with the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not resolve an event with the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  aget '/stashes.json' do
    begin
      http = EM::HttpRequest.new($api_server + '/stashes').get
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not retrieve a list of stashes from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve a list of stashes from the sensu api"}'
    end

    http.callback do
      status http.response_header.status
      body http.response
    end
  end

  apost '/stashes.json' do
    begin
      request_options = {
        :body => request.body.read,
        :head => {
          'content-type' => 'application/json'
        }
      }
      http = EM::HttpRequest.new($api_server + '/stashes').post request_options
    rescue => e
      $logger.warning(e)
      status 404
      body '{"error":"could not retrieve a list of stashes from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve a list of stashes from the sensu api"}'
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
