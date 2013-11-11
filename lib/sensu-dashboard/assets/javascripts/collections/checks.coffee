namespace "SensuDashboard.Collections", (exports) ->

  class exports.Checks extends SensuDashboard.Collections.Base
    model: SensuDashboard.Models.Check,
    url: "/checks"

    comparator: (event) ->
      event.get "name"

    getSelected: ->
      @where(selected: true)

    toggleSelected: ->
      selected = true
      selected = false if @getSelected().length == @length
      @each (client) ->
        client.set(selected: selected)

    selectAll: ->
      @each (client) ->
        client.set(selected: true)

    selectNone: ->
      @each (client) ->
        client.set(selected: false)
        
    requestSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for check in @getSelected()
        check.request
          success: (model) =>
            @successCallback.call(this, model) if @successCallback
            @selectNone()
          error: (model) =>
            @errorCallback.call(this, model) if @errorCallback
            @selectNone()