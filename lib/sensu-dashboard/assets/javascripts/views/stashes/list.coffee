namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.List extends SensuDashboard.Views.List

    name: 'stashes/list'

    itemClass: ->
      exports.ListItem
