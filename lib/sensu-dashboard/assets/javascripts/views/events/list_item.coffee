namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: 'events/list_item'

    className: ->
      @model.get('status_name')

    events:
      'click td:not(.select)': 'showDetails'
      'click input[type=checkbox]': 'toggleSelect'

    toggleSelect: ->
      @model.set({ selected: !@model.get('selected') })

    showDetails: ->
      new SensuDashboard.Views.Modal
        name: 'events/modal'
        model:
          event: @model.toJSON()
          client: SensuDashboard.Clients.get(@model.get('client')).toJSON()
          stashes: SensuDashboard.Stashes.toJSON()
