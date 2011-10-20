require 'eventmachine'
require 'sinatra/async'
require 'em-http-request'
require 'em-websocket'
require 'sass'
require 'json'
require 'sensu/config'

options = Sensu::Config.read_arguments(ARGV)
config = Sensu::Config.new(options)
SETTINGS = config.settings

EventMachine.run do

  class DashboardServer < Sinatra::Base

    register Sinatra::Async
    set :root, File.dirname(__FILE__)
    set :static, true
    set :public_folder, Proc.new { File.join(root, "public") }

    api_server = 'http://' + SETTINGS['api']['host'] + ':' + SETTINGS['api']['port'].to_s

    use Rack::Auth::Basic do |user, password|
      user == SETTINGS['dashboard']['user'] && password == SETTINGS['dashboard']['password']
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

    aget '/css/sonian.css' do
      content_type 'text/css'
      body sass :sonian
    end

    # api proxy
    aget '/events.json' do
      begin
        http = EventMachine::HttpRequest.new("#{api_server}/events").get
      rescue => e
        puts e
        status 404
        body '{"error":"could not retrieve alerts from the sensu api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve alerts from the sensu api"}'
      end

      http.callback do
        status http.response_header.status
        body http.response
      end
    end

    # api proxy
    aget '/events_clients.json' do
      begin
        http = EventMachine::HttpRequest.new("#{api_server}/events").get
      rescue => e
        puts e
        status 404
        body '{\"error\":\"could not retrieve alerts from the sensu api\"}'
      end

      http.errback do
        status 404
        body '{\"error\":\"could not retrieve alerts from the sensu api\"}'
      end

      http.callback do
        status http.response_header.status
        result = JSON.parse(http.response)

        # searching by client name, status
        clients = []
        statuses = {:warning => [], :critical => [], :unknown => []}
        result.each do |client, data|
          clients.push({:value => client, :name => client})
          data.each do |check_name, check_data|
            status = check_data["status"]
            if status == 1
              statuses[:warning].push(client)
            elsif status == 2
              statuses[:critical].push(client)
            else
              statuses[:unknown].push(status)
            end
          end
        end

        # searching by status
        statuses.each do |k, v|
          clients.push({:value => v.join(','), :name => k})
        end

        body clients.to_json
      end
    end

    aget '/clients.json' do
      begin
        http = EventMachine::HttpRequest.new("#{api_server}/clients").get
      rescue => e
        puts e
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
        http = EventMachine::HttpRequest.new("#{api_server}/client/#{id}").get
      rescue => e
        puts e
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

    aget '/stash/*.json' do |path|
      begin
        http = EventMachine::HttpRequest.new("#{api_server}/stash/#{path}").get
      rescue => e
        puts e
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
        http = EventMachine::HttpRequest.new("#{api_server}/stash/#{path}").post :body => request.body.read
      rescue => e
        puts e
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
        http = EventMachine::HttpRequest.new("#{api_server}/stash/#{path}").delete
      rescue => e
        puts e
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

    websocket_connections = Array.new
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 9000) do |websocket|
      websocket.onopen do
        websocket_connections.push websocket
        puts 'client connected to websocket'
      end
      websocket.onclose do
        websocket_connections.delete websocket
        puts 'client disconnected from websocket'
      end
    end

    apost '/events.json' do
      unless websocket_connections.empty?
        websocket_connections.each do |websocket|
          websocket.send '{"update":"true"}'
        end
      end
      body '{"success":"triggered dashboard refresh"}'
    end
  end

  DashboardServer.run!({:port => SETTINGS['dashboard']['port']})

  #
  # Recognize exit command
  #
  Signal.trap("INT") do
    EM.stop
  end
  Signal.trap("TERM") do
    EM.stop
  end

end
