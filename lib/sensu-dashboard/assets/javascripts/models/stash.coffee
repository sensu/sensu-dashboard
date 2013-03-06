namespace 'SensuDashboard.Models', (exports) ->

  class exports.Stash extends Backbone.Model

    defaults:
      id: 'silence'
      payload: {}

    initialize: ->
