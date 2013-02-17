namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends Backbone.View

    el: $('#main')

    name: 'events/index'

    initialize: ->
      @template = HandlebarsTemplates[@name]
      @listenTo(@collection, 'all', @render)

    addOne: (item) ->


    addAll: ->
      @$el.empty()
      @$el.html(@template(events: @collection.toJSON()))

    render: ->
      @addAll()
      return this
