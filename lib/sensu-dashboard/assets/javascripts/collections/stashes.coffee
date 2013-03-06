namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Stashes extends Backbone.Collection
    model: SensuDashboard.Models.Stash,
    url: '/stashes'
