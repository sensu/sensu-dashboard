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

    # api proxy
    aget '/autocomplete.json' do
      multi = EventMachine::MultiRequest.new

      requests = [
        "#{api_server}/events",
        "#{api_server}/clients"
      ]

      requests.each do |url|
        multi.add EventMachine::HttpRequest.new(url).get
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

          clients.each do |client|
            client_name = client['name']
            if events.include?(client_name)
              autocomplete.push({:value => client_name, :name => client_name})
              client['subscriptions'].each do |subscription|
                subscriptions[subscription] ||= []
                subscriptions[subscription].push(client_name)
              end
              events[client_name].each do |check, event|
                case event["status"]
                when 1
                  statuses[:warning].push(client_name)
                when 2
                  statuses[:critical].push(client_name)
                else
                  statuses[:unknown].push(client_name)
                end
              end
            end
          end

          # searching by subscription
          subscriptions.each do |k, v|
            autocomplete.push({:value => v.join(','), :name => k})
          end

          # searching by status
          statuses.each do |k, v|
            autocomplete.push({:value => v.join(','), :name => k})
          end

          body autocomplete.to_json
        else
          status 404
          body '{"error":"could not retrieve events and/or clients from the sensu api"}'
        end
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
        puts request.body.read
        request_options = {
          :body => {'timestamp' => Time.now.to_i}.to_json,
          :head => {
            'content-type' => 'application/json'
          }
        }
        http = EventMachine::HttpRequest.new("#{api_server}/stash/#{path}").post request_options
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
