# TokenField
#
# Author: Bjarne Mogstad
# Url: https://github.com/mogstad/token-field

class @TokenField extends Backbone.View
  tagName: "ul"
  className: "token-field"
  events:
    "blur input": ->
      @$el.removeClass("focus")
      @selectTokenAtIndex(Infinity)
    "focus input": ->
      @$el.addClass("focus")
    "click": ->
      @inputTester.focus()
    "click input": ->
      @selectTokenAtIndex(Infinity)
    "keyup input": "keyup"
    "keydown input": "keydown"
    "keypress input": "keypress"
    "mousedown ul li": (e) ->
      e.preventDefault()
    "click ul li": "clickToken"
    "click .close": "clickToCloseToken"

  initialize: (options = {}) ->
    super
    @selectedIndex = Infinity
    @tokens = []
    @delegate = options.delegate

  render: ->
    @container = document.createElement("li")
    @container.className = "tokens"

    @textContent = document.createElement("span")
    @inputTester = document.createElement("input")
    @inputTester.setAttribute("placeholder", "Add filters...")
    @inputTester.setAttribute("autocorrect", "off")
    @inputTester.setAttribute("autocapitalize", "off")
    @inputTester.setAttribute("autocomplete", "off")

    @container.appendChild(@textContent)
    @container.appendChild(@inputTester)

    @el.appendChild(@container)

    return this

  insertToken: (object) ->
    token = @prepareObject(object)
    @el.insertBefore(token.node, @container)
    @tokens.push(token)

  prepareObject: (object) ->
    data = @delegate.visualisationForObject(object, this)
    if _.isString data
      node = document.createElement("li")
      node.innerHTML = data

    token = {object: object, node: node || data}
    return token

  tokenize: ->
    string = @inputTester.value
    object = @delegate.objectForString(string, this)
    @insertToken(object)
    @textContent.innerHTML = @inputTester.value = ""

  selectPreviousToken: ->
    if @selectedIndex < 1
      return

    if @selectedIndex == Infinity
      @selectTokenAtIndex(@tokens.length - 1)
    else
      @selectTokenAtIndex(@selectedIndex - 1)

  selectNextToken: ->
    if @selectedIndex == Infinity
      return

    if @selectedIndex < @tokens.length - 1
      @selectTokenAtIndex(@selectedIndex + 1)
    else
      @selectTokenAtIndex(Infinity)

  selectTokenAtIndex: (index) ->
    if @selectedIndex != Infinity
      $(@tokens[@selectedIndex].node).removeClass("selected")

    if index == Infinity
      @selectedIndex = Infinity
      @$el.removeClass("selected-token")
      return

    if 0 <= index < @tokens.length
      @selectedIndex = index
      @$el.addClass("selected-token") if @inputTester.value.length == 0
      $(@tokens[@selectedIndex].node).addClass("selected")

  deleteTokenAtIndex: (index, deselect) ->
    if index < @tokens.length
      token = @tokens.splice(index, 1)
      @el.removeChild(token[0].node)
      if !deselect
        @selectedIndex = Infinity
        if @tokens.length
          @selectTokenAtIndex(Math.max(index - 1, 0))
        else
          @selectTokenAtIndex(Infinity)

  clickToken: (e) ->
    e.stopPropagation()
    target = e.currentTarget

    if (index = @_indexForTarget(target)) >= 0
      @selectTokenAtIndex(index)

    @inputTester.focus()

  clickToCloseToken: (e) ->
    e.stopPropagation()
    target = $(e.currentTarget).closest("li")[0]
    return if (index = @_indexForTarget(target)) < 0
    @deleteTokenAtIndex(index, true)

    return if @selectedIndex == Infinity

    if @tokens.length == 0
      @selectedIndex = Infinity
      @selectTokenAtIndex(Infinity)
      return

    if index <= @selectedIndex
      @selectedIndex = Math.max(index - 1, 0)

    return

  _indexForTarget: (target) ->
    for token, index in @tokens when target == token.node
      return index

  keyup: (e) ->
    @textContent.innerHTML = @inputTester.value
    switch e.keyCode
      when 13
        @tokenize()

  keydown: (e) ->
    switch e.keyCode
      when 8 # Backspace
        if @selectedIndex != Infinity
          @deleteTokenAtIndex(@selectedIndex)
          e.preventDefault()
        else if @inputTester.selectionStart == 0 && @inputTester.selectionEnd == 0
          @selectTokenAtIndex(@tokens.length - 1)
          e.preventDefault()
      when 37 # Left arrow
        if @inputTester.selectionStart == 0 || @selectedIndex != Infinity
          e.preventDefault()
          @selectPreviousToken()
      when 39 # Right arrow
        if @selectedIndex != Infinity
          e.preventDefault()
          @selectNextToken()

  keypress: (e) ->
    if @selectedIndex != Infinity
      @deleteTokenAtIndex(@selectedIndex, true)
      @selectedIndex = Infinity
      @selectTokenAtIndex(Infinity)
