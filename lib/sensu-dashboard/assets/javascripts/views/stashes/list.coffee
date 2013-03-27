namespace "SensuDashboard.Views.Stashes", (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: "stashes/list"

    initialize: ->
      @autocomplete_view = @options.autocomplete_view
      @autocomplete_view.delegate = this
      super

    itemClass: ->
      exports.ListItem

    resolvedCollection: ->
      resolved = @collection.chain()
      for token in @autocomplete_view.tokens
        resolved = if _.isString(token.object)
          resolved.filter (record) =>
            _.detect(record.get("path").split("/"), (part) =>
              liquidMetal.score(part, token.object) > 0.9) != undefined


      resolved

    resolved: ->
      _(@resolvedCollection().map().value())

    renderCollection: (collection) ->
      super(collection || @resolved())

    renderEmpty: (collection) ->
      super(collection || @resolved())

    #
    # Autocomplete delegate
    #

    filtersUpdated: ->
      filtered = @resolved()
      @collection.each (model) ->
        model.set(selected: false) unless filtered.contains(model)

      @$el.html(@template())
      @renderCollection(filtered)
