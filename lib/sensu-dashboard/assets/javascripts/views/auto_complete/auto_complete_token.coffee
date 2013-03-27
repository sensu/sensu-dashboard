namespace "SensuDashboard.Views", (exports) ->

  class exports.AutoCompleteToken extends exports.Base

    tagName: "li"
    className: "token"

    initialize: ->
      @delegate = @options.delegate
      @setItem(@options.item)

    setItem: (item) ->
      @item = item
      @type = if item instanceof SensuDashboard.Models.Check
        "check"
      else if item instanceof SensuDashboard.Models.Client
        "client"
      else
        "query"

    context: ->
      if _.isString @item
        { query: @item }
      else
        @item.toJSON()

    render: ->
      tmpl = HandlebarsTemplates["autocomplete/results_#{@type}_token"]
      @$el.html(tmpl(@context()))

      return this
