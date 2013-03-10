namespace 'SensuDashboard.Models', (exports) ->

  class exports.Check extends Backbone.Model

    defaults:
      handlers: ["default"]
      standalone: false
      subscribers: ["all"]
      interval: 60
