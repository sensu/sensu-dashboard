require 'sensu/base'
require 'thin'
require 'sinatra/async'
require 'em-http-request'
require 'slim'
require 'sass'

class Dashboard < Sinatra::Base
  register Sinatra::Async

  def self.run(options={})
    EM::run do
      self.setup(options)

      Thin::Logging.silent = true
      Thin::Server.start(self, $settings[:dashboard][:port])

      %w[INT TERM].each do |signal|
        Signal.trap(signal) do
          self.stop(signal)
        end
      end
    end
  end

  def self.setup(options={})
    $logger = Cabin::Channel.get
    base = Sensu::Base.new(options)
    $settings = base.settings
    unless $settings[:dashboard].is_a?(Hash)
      raise('missing dashboard configuration')
    end
    unless $settings[:dashboard][:port].is_a?(Integer)
      raise('dashboard must have a port')
    end
    unless $settings[:dashboard][:user].is_a?(String) && $settings[:dashboard][:password].is_a?(String)
      raise('dashboard must have a user and password')
    end
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
  set :haml, { :format => :html5 }

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
      $api_options[:head]['Accept'] = 'application/json'
      http = EM::HttpRequest.new($api_url + '/' + path).get($api_options)
    rescue => e
      $logger.warn(e.to_s)
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
    EM::PeriodicTimer.new(0.25) do
      EM::stop_event_loop
    end
  end
end

options = Sensu::CLI.read
Dashboard.run(options)
