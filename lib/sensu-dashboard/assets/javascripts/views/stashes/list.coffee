namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: 'stashes/list'

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
            _.detect(record.get('path').split("/"), (part) =>
              liquidMetal.score(part, token.object) > 0.9) != undefined


      resolved

    renderCollection: ->
      @resolvedCollection().each (event) =>
        @renderItem(event)

    #
    # Autocomplete delegate
    #

    filtersUpdated: ->
      @render()
