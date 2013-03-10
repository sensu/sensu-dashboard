namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'stashes/index'

    initialize: (collection) ->
      @template = HandlebarsTemplates[@name]
      @collection = collection
      @listenTo(collection, 'reset', @render)
      @listenTo(collection, 'change', @render)
      @render()

    addAll: ->
      @$el.empty()
      @$el.html(@template({ stashes: @collection }))

    render: ->
      @addAll()
