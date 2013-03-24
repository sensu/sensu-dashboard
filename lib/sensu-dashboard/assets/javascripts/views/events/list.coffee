namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: 'events/list'

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
            record.get('check') == model.get('name')
        else if model instanceof SensuDashboard.Models.Client
          resolved.filter (record) ->
            record.get('client') == model.get('name')
        else if _.isString(model)
          resolved.filter (record) ->
            liquidMetal.score(record.get('output'), model) > 0.7

      resolved

    renderCollection: ->
      @resolvedCollection().each (event) =>
        @renderItem(event)

    #
    # Autocomplete delegate
    #

    filtersUpdated: ->
      @render()
