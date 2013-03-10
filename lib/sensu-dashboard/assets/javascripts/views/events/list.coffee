namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.List extends SensuDashboard.Views.Base

    name: 'events/list'

    initialize: (collection) ->
      @template = HandlebarsTemplates[@name]
      _.bindAll(this, 'addOne')
      @collection = collection
      @listenTo(@collection, 'reset', @render)
      @listenTo(@collection, 'add', @addOne)

    addOne: (event) ->
      item_subview = new SensuDashboard.Views.Events.Item({ model: event })
      @$el.find('tbody').append(item_subview.render().el)

    addAll: ->
      @collection.each(@addOne)

    render: ->
      @$el.html(@template(@collection.toJSON()))
      @addAll()
      return this

