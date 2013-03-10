namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: 'clients/list_item'

    className: ->
      @model.get('name')
