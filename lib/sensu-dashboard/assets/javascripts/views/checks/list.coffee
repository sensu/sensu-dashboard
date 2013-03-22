namespace 'SensuDashboard.Views.Checks', (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: 'checks/list'

    itemClass: ->
      exports.ListItem
