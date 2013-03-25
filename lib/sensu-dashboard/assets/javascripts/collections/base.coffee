namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Base extends Backbone.Collection
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
