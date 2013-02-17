namespace 'SensuDashboard.Models', (exports) ->

  class exports.EventsMetadata extends Backbone.Model

    defaults:
      warning: 0
      critical: 0
      unknown: 0

    initialize: ->
