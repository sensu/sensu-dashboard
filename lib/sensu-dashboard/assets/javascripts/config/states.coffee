namespace 'SensuDashboard', (exports) ->

  exports.States = new exports.StateManager {

    events: class extends exports.MainState
      route: "events"
      view: (opts) ->
        new SensuDashboard.Views.Events.Index(model: SensuDashboard.EventsMetadata)

    clients: class extends exports.MainState
      route: "clients"
      view: (opts) ->
        new SensuDashboard.Views.Clients.Index(collection: SensuDashboard.Clients)

    stashes: class extends exports.MainState
      route: "stashes"
      view: (opts) ->
        new SensuDashboard.Views.Stashes.Index(collection: SensuDashboard.Stashes)

    health: class extends exports.MainState
      route: "stashes"
      view: (opts) ->
        new SensuDashboard.Views.Health.Index(model: SensuDashboard.Health)

  }, "events"
