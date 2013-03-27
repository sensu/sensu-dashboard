namespace "SensuDashboard.Views.Stashes", (exports) ->

  class exports.Counts extends SensuDashboard.Views.Base

    name: "stashes/counts"

    initialize: (collection) ->
      @listenTo(@collection, "all", @render)

    render: ->
      template_data = { count: @collection.models.length }
      @$el.html(@template(template_data))
      this
