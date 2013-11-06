namespace "SensuDashboard.Models", (exports) ->

  class exports.Check extends Backbone.Model

    defaults:
      handlers: ["default"]
      standalone: false
      subscribers: []
      interval: 60

    idAttribute: "name"

    initialize: ->

    
    request: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error