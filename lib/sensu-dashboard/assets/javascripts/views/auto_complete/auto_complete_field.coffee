namespace 'SensuDashboard.Views', (exports) ->

  class exports.AutoCompleteField extends TokenField

    name: "auto_complete_field"
    className: "token-field"
    placeholder: ""
    minInputValue: 2
    popoverVisible: false

    initialize: ->
      super

      @matcher = new SensuDashboard.Matcher(sources: @options.sources)

      @resultsView = @options.resultsView || new SensuDashboard.Views.AutoCompleteResults(@options.resultsViewOptions)
      @resultsView.setDelegate(this)
      @resultsView.on("item:selected", @tokenize, this)

      @delegate = @options.delegate

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

    tokenize: ->
      object = @resultsView.AutoCompleteTokenFieldItemSelected()
      @inputTester.focus()
      @insertToken(object)
      @textContent.innerHTML = @inputTester.value = ""

    _filterCollection: (query) ->
      results = @matcher.query(query)
      results.push(query)
      results

    queryMeetsMinLength: (query = @inputTester.value) ->
      query.trim().length >= @minInputValue

    keydown: (e) ->
      switch e.keyCode
        when 8
          @_queryEntered(@inputTester.value)
        else
          @resultsView.keyDown(e)

      super

    keyup: (e) ->
      switch e.keyCode
        when 38, 40
          # Prevent re-rendering when navigating auto-completer
          return false

      @_queryEntered(@inputTester.value)
      super

    keypress: (e) ->
      if e.keyCode == 13 && @inputTester.value == ""
        @_submit()
        e.preventDefault()
        return

      super

    _submit: ->
      @trigger("submit")

    _blur: (e) ->
      super
      @resultsView.AutoCompleteTokenFieldBlur()

    _queryEntered: (query) ->
      if @queryMeetsMinLength(query)
        @_showPopover(@_filterCollection(query))
      else
        @resultsView.AutoCompleteTokenFieldEmpty(false)

    # Other

    _showPopover: _.debounce((collection) ->
      unless @inputTester.value == ""
        $(@placeholderContent).hide()

        unless @queryMeetsMinLength()
          return @resultsView.AutoCompleteTokenFieldEmpty()

        @resultsView.setCollection(collection)
        @resultsView.AutoCompleteTokenFieldResults()
      else
        $(@placeholderContent).show()
        @resultsView.AutoCompleteTokenFieldEmpty()
    , 75)

    _hidePopover: ->
      @$el.popover 'hide', =>
        @popoverVisible = false

    destroy: ->
      @resultsView.off null, null, this
      super
