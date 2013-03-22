namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Base extends Backbone.Collection
    longPolling: false

    intervalSeconds: 10

    startLongPolling: (intervalSeconds) =>
      @longPolling = true
      if intervalSeconds
        @intervalSeconds = @intervalSeconds
      @executeLongPolling()

    stopLongPolling: =>
      @longPolling = false

    executeLongPolling: =>
      @fetch
        success: =>
          @onFetch()

    onFetch: =>
      setTimeout(@executeLongPolling, 10000) if @longPolling
