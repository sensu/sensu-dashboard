namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'clients/index'

    initialize: (collection) ->
      @template = HandlebarsTemplates[@name]
      @collection = collection
      @listenTo(collection, 'reset', @render)
      @listenTo(collection, 'change', @render)
      @render()

    addAll: ->
      @$el.empty()
      @$el.html(@template({ clients: @collection }))

    render: ->
      @addAll()
      return this
