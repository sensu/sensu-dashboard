namespace 'SensuDashboard.Models', (exports) ->

  class exports.Client extends Backbone.Model

    defaults:
      name: null
      address: null
      subscriptions: []
      timestamp: 0
      selected: false

    idAttribute: 'name'
