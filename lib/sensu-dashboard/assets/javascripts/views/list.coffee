namespace "SensuDashboard.Views", (exports) ->

  class exports.List extends SensuDashboard.Views.Base

    collectionEl: "tbody"

    itemName: "list_item"

    itemClass: ->
      exports.ListItem

    itemView: (model) ->
      kls = @itemClass()
      view = new kls(model: model, name: @itemName)

    initialize: ->
      @listenTo(@collection, "remove", @renderEmpty)
      @listenTo(@collection, "reset", @render)
      @listenTo(@collection, "add", @render)

    addItem: (item) ->
      @renderItem(item)
      @collection.sort()

    renderItem: (item) ->
      item_view = @itemView(item)
      @$el.find(@collectionEl).append(item_view.render().el)

    renderCollection: (collection = @collection) ->
      unless @renderEmpty(collection)
        collection.each (item) =>
          @renderItem(item)

    renderEmpty: (collection = @collection) ->
      if collection.isEmpty()
        tmpl = HandlebarsTemplates["empty_list"]
        @$el.html(tmpl())
        true
      else
        false

    render: ->
      @$el.html(@template())
      @renderCollection()
