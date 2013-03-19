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

    removeSelected: ->
      @each (stash) ->
        stash.remove()
