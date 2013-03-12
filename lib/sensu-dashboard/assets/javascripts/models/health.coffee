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
