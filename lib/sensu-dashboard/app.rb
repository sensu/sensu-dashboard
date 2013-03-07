require 'sensu/base'
require 'json'
require 'thin'
require 'sinatra/async'
require 'em-http-request'
require 'sass'

class Dashboard < Sinatra::Base
  register Sinatra::Async

  def self.run(options={})
    EM::run do
      self.setup(options)

      Thin::Logging.silent = true
      Thin::Server.start($settings[:dashboard][:host], $settings[:dashboard][:port], self)

      %w[INT TERM].each do |signal|
        Signal.trap(signal) do
          self.stop(signal)
        end
      end
    end
  end

  def self.non_reachable?(host)
    ["localhost","127.0.0.1","::1"].include?(host.to_s.downcase)
  end

  def self.setup(options={})
    base = Sensu::Base.new(options)
    $logger = base.logger
    $settings = base.settings
    unless $settings[:dashboard].is_a?(Hash)
      raise('missing dashboard configuration')
    end
    unless $settings[:dashboard][:port].is_a?(Integer)
      raise('dashboard must have a port')
    end
    $settings[:dashboard][:host] ||= "0.0.0.0"
    unless non_reachable?($settings[:dashboard][:host]) # If we are not route-able, the proxy is responsible for auth
      unless $settings[:dashboard][:user].is_a?(String) && $settings[:dashboard][:password].is_a?(String)
        raise('dashboard must have a user and password')
      end
    end
    base.setup_process
    $api_url = 'http://' + $settings[:api][:host] + ':' + $settings[:api][:port].to_s
    $api_options = {}
    if $settings[:api][:user] && $settings[:api][:password]
      $api_options.merge!(:head => {:authorization => [$settings[:api][:user], $settings[:api][:password]]})
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
  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      return true if Dashboard.non_reachable?($settings[:dashboard][:host]) # if reachable?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [$settings[:dashboard][:user],$settings[:dashboard][:password]]
    end
  end

  before do
    content_type 'application/json'
    request_log(env)
    protected!
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
    body '{"error": "this feature has been removed"}'
  end

  aget '/autocomplete.json' do
    multi = EM::MultiRequest.new
    multi.add :events, EM::HttpRequest.new($api_url + '/events').get($api_options)
    multi.add :clients, EM::HttpRequest.new($api_url + '/clients').get($api_options)

    multi.callback do
      unless multi.responses[:errback].size > 0
        events = JSON.parse(multi.responses[:callback][:events].response)
        clients = JSON.parse(multi.responses[:callback][:clients].response)

        autocomplete = []
        statuses = {:warning => [], :critical => [], :unknown => []}
        subscriptions = {}
        checks = []

        # searching by client
        clients.each do |client|
          client_name = client['name']
          autocomplete.push({:value => [client_name], :type => 'client', :name => client_name})
          client['subscriptions'].each do |subscription|
            subscriptions[subscription] ||= []
            subscriptions[subscription].push(client_name)
          end
          events.each do |event|
            case event['status']
            when 1
              statuses[:warning].push(event['status'])
            when 2
              statuses[:critical].push(event['status'])
            else
              statuses[:unknown].push(event['status'])
            end
            checks.push(event['check'])
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
    begin
      http = EM::HttpRequest.new($api_url + '/clients').get($api_options)
    rescue => e
      $logger.warn(e.to_s)
      status 404
      body '{"error":"could not retrieve clients from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve clients from the sensu api"}'
    end

    http.callback do
      if http.response_header.status == 200
        clients = JSON.parse(http.response)
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
      http = EM::HttpRequest.new($api_url + '/events').get($api_options)
    rescue => e
      $logger.warn(e.to_s)
      status 404
      body '{"error":"could not retrieve events from the sensu api"}'
    end

    http.errback do
      status 404
      body '{"error":"could not retrieve events from the sensu api"}'
    end

    http.callback do
      events = Hash.new
      if http.response_header.status == 200
        api_events = JSON.parse(http.response)
        api_events.each do |event|
          client = event.delete('client')
          check = event.delete('check')
          events[client] ||= Hash.new
          events[client][check] = event
        end
      end
      status http.response_header.status
      body events.to_json
    end
  end

  aget '/clients.json' do
    begin
      http = EM::HttpRequest.new($api_url + '/clients').get($api_options)
    rescue => e
      $logger.warn(e.to_s)
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
      http = EM::HttpRequest.new($api_url + '/client/' + id).get($api_options)
    rescue => e
      $logger.warn(e.to_s)
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
      http = EventMachine::HttpRequest.new($api_url + '/client/' + id).delete($api_options)
    rescue => e
      $logger.warn(e.to_s)
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
      http = EM::HttpRequest.new($api_url + '/stash/' + path).get($api_options)
    rescue => e
      $logger.warn(e.to_s)
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
      http = EM::HttpRequest.new($api_url + '/stash/' + path).post(request_options.merge($api_options))
    rescue => e
      $logger.warn(e.to_s)
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
      http = EM::HttpRequest.new($api_url + '/stash/' + path).delete($api_options)
    rescue => e
      $logger.warn(e.to_s)
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
      http = EM::HttpRequest.new($api_url + '/event/resolve').post(request_options.merge($api_options))
    rescue => e
      $logger.warn(e.to_s)
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
      http = EM::HttpRequest.new($api_url + '/stashes').get($api_options)
    rescue => e
      $logger.warn(e.to_s)
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
      http = EM::HttpRequest.new($api_url + '/stashes').post(request_options.merge($api_options))
    rescue => e
      $logger.warn(e.to_s)
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
    EM::PeriodicTimer.new(0.25) do
      EM::stop_event_loop
    end
  end
end

options = Sensu::CLI.read
Dashboard.run(options)
