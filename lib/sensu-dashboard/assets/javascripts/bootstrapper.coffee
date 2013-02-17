namespace 'SensuDashboard', (exports) ->

  class exports.Bootstrapper

    constructor: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error

      @events = new SensuDashboard.Collections.Events
      @events.fetch
        success: (collection, response) ->
          SensuDashboard.EventsView = new SensuDashboard.Views.Events.Index(collection: collection)
        error: (collection, response) ->
          console.log("Failed to fetch expenses collection " + response)

      @successCallback.call(this)
      #@errorCallback.call(this)
