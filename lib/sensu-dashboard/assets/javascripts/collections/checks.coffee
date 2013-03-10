namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Checks extends Backbone.Collection
    model: SensuDashboard.Models.Check,
    url: '/checks'

    comparator: (event) ->
      event.get 'name'
