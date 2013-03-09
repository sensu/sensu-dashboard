namespace 'SensuDashboard.Models.Metadata', (exports) ->

  class exports.Events extends Backbone.Model

    defaults:
      total: 0
      warning: 0
      critical: 0
      unknown: 0

    initialize: ->
      SensuDashboard.Events.on 'all', @updateCounts, this
      SensuDashboard.Stashes.on 'all', @updateCounts, this
      @updateCounts()

    updateCounts: ->
      @set
        events: SensuDashboard.Events
        stashes: SensuDashboard.Stashes.toJSON()
        total: SensuDashboard.Events.length
        warning: SensuDashboard.Events.where({status: 1}).length
        critical: SensuDashboard.Events.where({status: 2}).length
        unknown: SensuDashboard.Events.where({status: 3}).length # TODO: check for all status codes that are not 1 or 2
