namespace 'SensuDashboard.Models.Metadata', (exports) ->

  class exports.Events extends Backbone.Model

    defaults:
      total: 0
      warning: 0
      critical: 0
      unknown: 0

    initialize: ->
      SensuDashboard.Events.on 'reset', @updateCounts, this

    updateCounts: (events) ->
      @set
        events: SensuDashboard.Events.toJSON()
        total: events.length
        warning: events.where({status: 1}).length
        critical: events.where({status: 2}).length
        unknown: events.where({status: 3}).length # TODO: check for all status codes that are not 1 or 2
