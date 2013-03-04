namespace 'SensuDashboard.Models.Metadata', (exports) ->

  class exports.Events extends Backbone.Model

    defaults:
      warning: 0
      critical: 0
      unknown: 0

    initialize: ->
      SensuDashboard.Events.on 'reset', @updateCounts, this

    updateCounts: (events) ->
      @set {warning: events.where({status: 1}).length}
      @set {critical: events.where({status: 2}).length}
      @set {unknown: events.where({status: 3}).length} # TODO: check for all status codes that are not 1 or 2

    parse: (response) ->
      console.log 'here'
      response.events = SensuDashboard.Events
      return response
