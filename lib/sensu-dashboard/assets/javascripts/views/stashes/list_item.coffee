namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: 'stashes/list_item'

    className: ->
      @model.get('status_name')
