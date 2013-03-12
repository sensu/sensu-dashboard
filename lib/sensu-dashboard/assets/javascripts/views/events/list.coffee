namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: 'events/list'

    itemClass: ->
      exports.ListItem
