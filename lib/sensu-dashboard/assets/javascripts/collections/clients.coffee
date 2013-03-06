namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Clients extends Backbone.Collection
    model: SensuDashboard.Models.Client,
    url: '/clients'

    comparator: (event) ->
      event.get 'name'
