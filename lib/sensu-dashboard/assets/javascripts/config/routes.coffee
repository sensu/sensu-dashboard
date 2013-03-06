namespace 'SensuDashboard', (exports) ->

  exports.Router = Backbone.Router.extend

    routes:
      "":        "events"
      "events":  "events"
      "stashes": "stashes"
      "clients": "clients"

    events: ->
      new SensuDashboard.Views.Events.Index(SensuDashboard.EventsMetadata)

    stashes: ->
      new SensuDashboard.Views.Stashes.Index(SensuDashboard.Stashes)

    clients: ->
      new SensuDashboard.Views.Clients.Index(SensuDashboard.Clients)
