namespace 'SensuDashboard.Models', (exports) ->

  class exports.Stash extends Backbone.Model

    defaults:
      path: 'silence'
      keys: []
      selected: false

    idAttribute: 'path'
