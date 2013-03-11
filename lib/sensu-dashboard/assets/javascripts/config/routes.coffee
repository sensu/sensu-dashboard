namespace 'SensuDashboard', (exports) ->

  exports.Router = Backbone.Router.extend

    routes:
      "":        "events"
      "events":  "events"
      "stashes": "stashes"
      "clients": "clients"
      "health":  "health"

    events: ->
      new SensuDashboard.Views.Events.Index(model: SensuDashboard.EventsMetadata)

    stashes: ->
      new SensuDashboard.Views.Stashes.Index(collection: SensuDashboard.Stashes)

    clients: ->
      new SensuDashboard.Views.Clients.Index(collection: SensuDashboard.Clients)

    health: ->
      new SensuDashboard.Views.Health.Index(model: SensuDashboard.Health)
