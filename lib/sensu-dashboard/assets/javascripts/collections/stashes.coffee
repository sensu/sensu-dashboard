namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Stashes extends Backbone.Collection
    model: SensuDashboard.Models.Stash,
    url: '/stashes'

    getSelected: ->
      @where(selected: true)

    toggleSelected: ->
      selected = true
      selected = false if @getSelected().length == @length
      @each (stash) ->
        stash.set(selected: selected)

    selectAll: ->
      @each (stash) ->
        stash.set(selected: true)

    selectNone: ->
      @each (stash) ->
        stash.set(selected: false)

    removeSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      @each (stash) ->
        stash.remove
          success: (model, xhr, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback
