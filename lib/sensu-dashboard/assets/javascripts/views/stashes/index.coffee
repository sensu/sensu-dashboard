namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'stashes/index'

    initialize: ->
      @stashes_view = new exports.List(collection: @collection)
      @render()

    render: ->
      @$el.html(@template(stashes: @collection))
      @assign(@stashes_view, '#stashes_container')
      this
