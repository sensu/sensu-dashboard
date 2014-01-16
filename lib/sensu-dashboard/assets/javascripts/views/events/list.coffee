namespace "SensuDashboard.Views.Events", (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: "events/list"

    initialize: ->
      @autocomplete_view = @options.autocomplete_view
      @autocomplete_view.delegate = this
      super

    itemClass: ->
      exports.ListItem

    resolvedCollection: ->
      resolved = @collection.chain()
      for token in @autocomplete_view.tokens
        model = token.object
        resolved = if model instanceof SensuDashboard.Models.Check
          resolved.filter (record) ->
            record.get("check") == model.get("name")
        else if model instanceof SensuDashboard.Models.Client
          resolved.filter (record) ->
            record.get("client") == model.get("name")
        else if _.isString(model)
          resolved.filter (record) ->
            output = record.get("check")["output"].toLowerCase()
            result = output.indexOf(model.toLowerCase()) != -1
            result || record.get("check")["name"].toLowerCase() == model.toLowerCase()

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
