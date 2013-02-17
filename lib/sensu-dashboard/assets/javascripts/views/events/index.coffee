namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends Backbone.View

    el: $('#main')

    name: 'events/index'

    initialize: ->
      @template = HandlebarsTemplates[@name]
      @listenTo(SensuDashboard.Events, 'all', @render)

    addOne: (item) ->


    addAll: ->
      @$el.empty()
      @$el.html(@template(SensuDashboard.EventsMetadata.toJSON()))

    render: ->
      console.log 'render'
      console.log SensuDashboard.EventsMetadata.toJSON()
      @addAll()
      return this
