namespace 'SensuDashboard', (exports) ->

  class exports.Bootstrapper

    constructor: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error

      try
        $.ajax
          type: 'GET'
          url: '/all'
          context: this
          dataType: 'json'
          success: (data, textStatus, jqXHR) ->
            SensuDashboard.PollFrequency = data.health.sensu_dashboard.poll_frequency
            SensuDashboard.Stashes = new SensuDashboard.Collections.Stashes(data.stashes)
            SensuDashboard.Events = new SensuDashboard.Collections.Events(data.events)
            SensuDashboard.Clients = new SensuDashboard.Collections.Clients(data.clients)
            SensuDashboard.Checks = new SensuDashboard.Collections.Checks(data.checks)
            SensuDashboard.EventsMetadata = new SensuDashboard.Models.Metadata.Events
            SensuDashboard.Health = new SensuDashboard.Models.Health(data.health)

            SensuDashboard.Stashes.startLongPolling(SensuDashboard.PollFrequency)
            SensuDashboard.Events.startLongPolling(SensuDashboard.PollFrequency)
            SensuDashboard.Clients.startLongPolling(SensuDashboard.PollFrequency)
            SensuDashboard.Checks.startLongPolling(SensuDashboard.PollFrequency)
            SensuDashboard.Health.startLongPolling(SensuDashboard.PollFrequency)

            @successCallback.call(this)
          error: (jqXHR, textStatus, errorThrown) ->
            console.log jqXHR.status+' '+jqXHR.statusText
            console.log errorThrown
            console.log textStatus
            console.log jqXHR
            @error()

      catch error
        @error()

    error: ->
      @errorCallback.call(this)
      return
