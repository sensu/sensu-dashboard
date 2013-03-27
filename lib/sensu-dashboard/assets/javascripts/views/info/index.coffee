namespace "SensuDashboard.Views.Info", (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    name: "info/index"

    initialize: ->
      @listenTo(@model, "destroy", @render)
      @listenTo(@model, "change", @render)

    render: ->
      @$el.html(@template(@model.toJSON()))
      this
