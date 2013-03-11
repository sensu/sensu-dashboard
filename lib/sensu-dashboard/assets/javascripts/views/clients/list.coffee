namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: 'clients/list'

    itemClass: ->
      exports.ListItem
