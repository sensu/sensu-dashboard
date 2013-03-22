namespace 'SensuDashboard', (exports) ->

  exports.Router = Backbone.Router.extend

    routes:
      "":        "events"
      "events":  "events"
      "stashes": "stashes"
      "clients": "clients"
      "checks":  "checks"
      "health":  "health"

    events: ->
      new SensuDashboard.Views.Events.Index(model: SensuDashboard.EventsMetadata)

    stashes: ->
      new SensuDashboard.Views.Stashes.Index(collection: SensuDashboard.Stashes)

    clients: ->
      new SensuDashboard.Views.Clients.Index(collection: SensuDashboard.Clients)

    checks: ->
      new SensuDashboard.Views.Checks.Index(collection: SensuDashboard.Checks)

    health: ->
      new SensuDashboard.Views.Health.Index(model: SensuDashboard.Health)
