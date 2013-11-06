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
        