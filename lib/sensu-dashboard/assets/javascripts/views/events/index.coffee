namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends Backbone.View

    el: $('#main')

    name: 'events/index'

    initialize: ->
      @template = HandlebarsTemplates[@name]
      @listenTo(SensuDashboard.Events, 'reset', @render)

    addOne: (item) ->


    addAll: ->
      @$el.empty()
      @$el.html(@template(SensuDashboard.EventsMetadata.toJSON()))

    render: ->
      @addAll()
      return this
