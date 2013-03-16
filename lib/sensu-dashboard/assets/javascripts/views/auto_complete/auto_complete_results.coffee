namespace 'SensuDashboard.Views', (exports) ->

  class exports.AutoCompleteResults extends exports.Base

    tagName: "ul"
    name: "autocomplete/results"
    className: "auto-complete-results"
    events:
      "mousedown li": (e) ->
        e.preventDefault()
        e.stopPropagation()
      "mouseup li": "selectItem"
      "mouseover li": "_mouseoverItem"
    visible: false

    initialize: (options) ->
      super

      @selectedIndex = -1
      @items = []

    setDelegate: (delegate) ->
      @delegate = delegate

    renderItem: (item, index) ->
      type = if item instanceof SensuDashboard.Models.Check
        "check"
      else if item instanceof SensuDashboard.Models.Client
        "client"
      else
        "query"
      context = if item.toJSON then item.toJSON() else { query: item }

      HandlebarsTemplates["#{@name}_#{type}_item"](context)

    renderCollection: ->
      @render()

      @$el.empty()
      for model in @collection
        @$el.append($(@renderItem(model)))

      @items = @$el.find("> li").toArray()
      @selectedIndex = -1
      @selectAtIndex(0)

      this

    setCollection: (collection) ->
      @collection = collection

    selectNext: ->
      item = @selectAtIndex(@selectedIndex + 1)
      item.scrollIntoViewIfNeeded(false) if item

    selectPrevious: ->
      item = @selectAtIndex(@selectedIndex - 1)
      item.scrollIntoViewIfNeeded(true) if item

    selectedObject: ->
      return @collection[@selectedIndex]

    selectAtIndex: (index) ->
      if 0 <= index < @items.length
        console.log(@$el.find(".selected"))
        @$el.find(".selected").removeClass("selected")
        item = @items[index]
        $(item).addClass("selected")
        @selectedIndex = index
        return item

    selectItem: ->
      return unless item = @selectedObject()
      @trigger("item:selected", item)

    deselectAll: ->
      @$el.find(".selected").removeClass("selected")

    #
    # Private
    #

    _mouseoverItem: (e) ->
      index = _.indexOf(@items, e.currentTarget)
      return if @selectedIndex == index

      @selectAtIndex index

    keyDown: (e) ->
      switch e.keyCode
        when 40
          e.preventDefault()
          @selectNext()
          return false

        when 38
          e.preventDefault()
          @selectPrevious()
          return false

      true

    _hide: ->
      if @visible
        @setElement($("<ul/>"))
        $(@delegate.inputTester).popover("hide")
        @visible = false

    #
    # Delegate
    #

    AutoCompleteTokenFieldEmpty: ->
      @_hide()

    AutoCompleteTokenFieldBlur: ->
      # ..

    AutoCompleteTokenFieldResults: ->
      @renderCollection()
      unless @visible
        $(@delegate.inputTester).popover({
          html: true
          content: @$el
          placement: 'bottom'
        }).popover("show")
        @setElement(@delegate.$el.find("div.popover-content ul.auto-complete-results")[0])
        @visible = true

    AutoCompleteTokenFieldItemSelected: ->
      @_hide()
      @selectedObject()
