namespace 'SensuDashboard', (exports) ->

  class exports.Bootstrapper

    constructor: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error

      SensuDashboard.Events = new SensuDashboard.Collections.Events
      SensuDashboard.EventsMetadata = new SensuDashboard.Models.Metadata.Events
      SensuDashboard.EventsView = new SensuDashboard.Views.Events.Index

      SensuDashboard.Events.fetch()

      @successCallback.call(this)
      #@errorCallback.call(this)
