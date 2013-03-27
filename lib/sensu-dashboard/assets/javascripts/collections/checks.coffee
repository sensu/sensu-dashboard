namespace "SensuDashboard.Collections", (exports) ->

  class exports.Checks extends SensuDashboard.Collections.Base
    model: SensuDashboard.Models.Check,
    url: "/checks"

    comparator: (event) ->
      event.get "name"
