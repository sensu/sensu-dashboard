namespace "SensuDashboard.Models.Metadata", (exports) ->

  class exports.Events extends Backbone.Model

    defaults:
      total: 0
      warning: 0
      critical: 0
      unknown: 0

    initialize: ->
      SensuDashboard.Events.on "all", @updateCounts, this
      @updateCounts()

    updateCounts: ->
      @set
        events: SensuDashboard.Events
        total: SensuDashboard.Events.length
        warning: SensuDashboard.Events.getWarnings().length
        critical: SensuDashboard.Events.getCriticals().length
        unknown: SensuDashboard.Events.getUnknowns().length
