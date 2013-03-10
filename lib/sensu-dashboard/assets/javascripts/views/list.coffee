namespace 'SensuDashboard.Views', (exports) ->

  class exports.List extends SensuDashboard.Views.Base

    collectionEl: 'tbody'

    itemName: "list_item"

    itemClass: ->
      exports.ListItem

    itemView: (model) ->
      kls = @itemClass()
      view = new kls(model: model, name: @itemName)

    initialize: ->
      @listenTo(@collection, 'reset', @render)
      @listenTo(@collection, 'add', @renderItem)

    renderItem: (item) ->
      item_view = @itemView(item)
      @$el.find(@collectionEl).append(item_view.render().el)

    renderCollection: ->
      @collection.each (item) =>
        @renderItem(item)

    render: ->
      @$el.html(@template())
      @renderCollection()
