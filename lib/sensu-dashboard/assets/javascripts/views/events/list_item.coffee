namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: 'events/list_item'

    className: ->
      @model.get('status_name')

    events:
      'click td:not(.select)': 'showDetails'
      'click input[type=checkbox]': 'toggleSelect'

    initialize: ->
      @client = SensuDashboard.Clients.get(@model.get('client'))
      @stashes = SensuDashboard.Stashes
      @listenTo(@client, 'remove', @remove)
      super

    toggleSelect: ->
      @model.set({ selected: !@model.get('selected') })

    showDetails: ->
      new SensuDashboard.Views.Events.Modal
        model: new Backbone.Model
          event: @model
          client: @client
