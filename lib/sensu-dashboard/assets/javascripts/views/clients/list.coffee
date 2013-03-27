namespace "SensuDashboard.Views.Clients", (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: "clients/list"

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
              { key: "address", threshold: 0.85 },
              { key: "name", threshold: 0.9 }
            )
            result || _.detect(record.get("subscriptions"), (sub) =>
              liquidMetal.score(sub, token.object) > 0.96) != undefined

      resolved

    matchForKeys: (q, record, args...) ->
      result = _.detect args, (options) =>
        value = record.get(options.key)
        score = liquidMetal.score(value, q)
        score >= (options.threshold || 0.7)

      !(result is undefined)

    renderCollection: ->
      super(_(@resolvedCollection().map().value()))

    renderEmpty: ->
      super(_(@resolvedCollection().map().value()))

    #
    # Autocomplete delegate
    #

    filtersUpdated: ->
      @render()
