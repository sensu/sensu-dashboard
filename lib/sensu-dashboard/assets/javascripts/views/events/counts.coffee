namespace "SensuDashboard.Views.Events", (exports) ->

  class exports.Counts extends SensuDashboard.Views.Base

    name: "events/counts"

    initialize: (model) ->
      @listenTo(@model, "all", @render)

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this
