namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Clients extends Backbone.Collection
    model: SensuDashboard.Models.Client,
    url: '/clients'

    comparator: (event) ->
      event.get 'name'

    toggleSelected: ->
      selected = true
      selected = false if @where({ selected: true }).length == @length
      @each (client) ->
        client.set { selected: selected }

    selectAll: ->
      @each (client) ->
        client.set { selected: true }

    selectNone: ->
      @each (client) ->
        client.set { selected: false }

    resolveSelected: ->
      console.log client for client in @where({ selected: true })

    silenceSelected: ->
      console.log client for client in @where({ selected: true })

    unsilenceSelected: ->
      console.log client for client in @where({ selected: true })
