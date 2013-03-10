namespace 'SensuDashboard.Models', (exports) ->

  class exports.Stash extends Backbone.Model

    defaults:
      path: 'silence'
      keys: []

    initialize: ->
      @set { id: @get('path') }
