namespace 'SensuDashboard.Models', (exports) ->

  class exports.Health extends Backbone.Model

    defaults:
      sensu:
        version: null
      dashboard:
        version: null
      rabbitmq:
        keepalives:
          messages: 0
          consumers: 0
        results:
          messages: 0
          consumers: 0
        connected: false
      redis:
        connected: false
      sensu_dashboard:
        version: null
        poll_frequency: 10

    url: '/health'

    initialize: ->
      @setRMQStatus   @get('rabbitmq').connected
      @setRedisStatus @get('redis').connected

    setRMQStatus: (status) ->
      @set { rmq_status: @_onlineStatus(status) }

    setRedisStatus: (status) ->
      @set { redis_status: @_onlineStatus(status) }

# Private
    _onlineStatus: (status) ->
      if status then 'Online' else 'Offline'

    longPolling: false

    intervalSeconds: 10

    startLongPolling: (intervalSeconds) =>
      @longPolling = true
      @intervalSeconds = intervalSeconds if intervalSeconds
      @executeLongPolling()

    stopLongPolling: =>
      @longPolling = false

    executeLongPolling: =>
      @fetch
        success: =>
          @onFetch()

    onFetch: =>
      setTimeout(@executeLongPolling, 1000 * @intervalSeconds) if @longPolling
