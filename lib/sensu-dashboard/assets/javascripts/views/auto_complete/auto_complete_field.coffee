namespace "SensuDashboard.Views", (exports) ->

  class exports.AutoCompleteField extends TokenField

    name: "auto_complete_field"
    className: "token-field"
    placeholder: ""
    minInputValue: 2
    maxResults: 9

    localEvents:
      "blur input": "_blur"
      "focus input": "_focus"
      "focusin input": "focusIn"
      "focusout input": "focusOut"

    focusIn: ->
      $("#filter").addClass("focus")

    focusOut: ->
      $("#filter").removeClass("focus")

    initialize: ->
      super

      @events = _.extend({}, @events, @localEvents)

      @matcher = new SensuDashboard.Matcher(sources: @options.sources)

      @resultsView = @options.resultsView || new SensuDashboard.Views.AutoCompleteResults(@options.resultsViewOptions)
      @resultsView.setDelegate(this)
      @resultsView.on("item:selected", @tokenize, this)

      this

    render: ->
      super

      @inputTester.setAttribute("placeholder", "")

      @placeholderContent = document.createElement("span")
      @placeholderContent.innerHTML = "Filter..."
      @container.appendChild(@placeholderContent)

      @textContent.className = "copy"

      @resultsView.setTarget?(@inputTester)

      return this

    addCollection: (collection) ->
      @matcher.addSource(collection)

    insertToken: (object) ->
      node = new exports.AutoCompleteToken(item: object).render()
      token = {object: object, node: node.el}
      @el.insertBefore(token.node, @container)
      @tokens.push(token)
      @delegate.filtersUpdated()
      $(@placeholderContent).show()

    tokenize: ->
      object = @resultsView.autoCompleteTokenFieldItemSelected()
      @inputTester.focus()
      @insertToken(object)
      @textContent.innerHTML = @inputTester.value = ""

    deleteTokenAtIndex: (index, deselect) ->
      super(index, deselect)
      @delegate.filtersUpdated()

    _filterCollection: (query) ->
      results = @matcher.query(query)
      results = _.first(results, @maxResults)
      results.push(query)
      results

    queryMeetsMinLength: (query = @inputTester.value) ->
      query.trim().length >= @minInputValue

    keydown: (e) ->
      @resultsView.keyDown(e)
      super

    keyup: (e) ->
      switch e.keyCode
        when 38, 40
          return false

      @textContent.innerHTML = @inputTester.value
      switch e.keyCode
        when 13
          @tokenize()
        else
          @_queryEntered(@inputTester.value)

    keypress: (e) ->
      if e.keyCode == 13 && @inputTester.value == ""
        @_submit()
        e.preventDefault()
        return

    _submit: ->
      @trigger("submit")

    _blur: (e) ->
      @$el.removeClass("focus")
      @selectTokenAtIndex(Infinity)
      @resultsView.autoCompleteTokenFieldBlur()

    _focus: (e) ->
      @$el.addClass("focus")
      @_queryEntered(@inputTester.value)

    _queryEntered: (query) ->
      if query.length > 0
        @selectTokenAtIndex(Infinity) unless @selectedIndex == Infinity
        $(@placeholderContent).hide()
      if @queryMeetsMinLength(query)
        @_showPopover(@_filterCollection(query))
      else
        @resultsView.autoCompleteTokenFieldEmpty(false)

    # Other

    _showPopover: _.debounce((collection) ->
        @resultsView.setCollection(collection)
        @resultsView.autoCompleteTokenFieldResults()
    , 75)

    destroy: ->
      @resultsView.off null, null, this
      super
