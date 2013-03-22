namespace 'SensuDashboard.Views.Checks', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'checks/index'

    initialize: ->
      @subview = new exports.List(collection: @collection)
      @render()

    render: ->
      @$el.html(@template(checks: @collection))
      @assign(@subview, '#checks_container')
      this
