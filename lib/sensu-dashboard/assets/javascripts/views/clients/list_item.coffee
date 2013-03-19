namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: 'clients/list_item'

    className: ->
      @model.get('name')

    events:
      'click td:not(.select)': 'showDetails'
      'click input[type=checkbox]': 'toggleSelect'

    toggleSelect: ->
      @model.set(selected: !@model.get('selected'))

    showDetails: ->
      new SensuDashboard.Views.Clients.Modal
        name: 'clients/modal'
        model: @model
