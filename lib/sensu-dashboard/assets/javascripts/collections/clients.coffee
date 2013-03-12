namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Clients extends Backbone.Collection
    model: SensuDashboard.Models.Client,
    url: '/clients'

    comparator: (event) ->
      event.get 'name'

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

    resolveSelected: ->
      console.log client for client in @getSelected()

    silenceSelected: ->
      console.log client for client in @getSelected()

    unsilenceSelected: ->
      console.log client for client in @getSelected()
