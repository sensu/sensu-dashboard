require 'eventmachine'
require 'sinatra/async'
require 'em-http-request'
require 'em-websocket'
require 'sass'
require 'sensu/config'

EventMachine.run do

  class DashboardServer < Sinatra::Base

    register Sinatra::Async
    set :root, File.dirname(__FILE__)
    set :static, true
    set :public_folder, Proc.new { File.join(root, "public") }

    options = Sensu::Config.read_arguments(ARGV)
    config = Sensu::Config.new(options)
    settings = config.settings
    secret = settings.has_key?('dashboard') ? settings['dashboard']['key'] : 'secret'
    api_server = 'http://' + settings['api']['host'] + ':' + settings['api']['port'].to_s

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
        body '{"error":"could not retrieve alerts from the monitoring api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve alerts from the monitoring api"}'
      end

      http.callback do
        body http.response
      end
    end

    aget '/clients.json' do
      begin
        http = EventMachine::HttpRequest.new("#{api_server}/clients").get
      rescue => e
        puts e
        status 404
        body '{"error":"could not retrieve clients from the monitoring api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve clients from the monitoring api"}'
      end

      http.callback do
        body http.response
      end
    end

    aget '/client/:id.json' do |id|
      begin
        http = EventMachine::HttpRequest.new("#{api_server}/client/#{id}").get
      rescue => e
        puts e
        status 404
        body '{"error":"could not retrieve clients from the monitoring api"}'
      end

      http.errback do
        status 404
        body '{"error":"could not retrieve clients from the monitoring api"}'
      end

      http.callback do
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
      if secret == JSON.parse(request.body.read)['secret']
        unless websocket_connections.empty?
          websocket_connections.each do |websocket|
            websocket.send '{"success":"true"}'
          end
        end
        body '{"success":"updated events"}'
      else
        status 400
        body '{"error":"invalid secret"}'
      end
    end

  end

  DashboardServer.run!({:port => 7070})

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
