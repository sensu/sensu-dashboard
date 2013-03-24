namespace 'SensuDashboard.Views.Checks', (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: 'checks/list'

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
            result = @matchForKeys(token.object, record,
              { key: 'interval', threshold: 1 },
              { key: 'name', threshold: 0.92 }
            )
            result || _.detect(record.get('subscribers'), (sub) =>
              liquidMetal.score(sub, token.object) > 0.96) != undefined

      resolved

    matchForKeys: (q, record, args...) ->
      result = _.detect args, (options) =>
        value = record.get(options.key).toString()
        score = liquidMetal.score(value, q)
        score >= (options.threshold || 0.7)

      !(result is undefined)

    renderCollection: ->
      @resolvedCollection().each (event) =>
        @renderItem(event)

    #
    # Autocomplete delegate
    #

    filtersUpdated: ->
      @render()
