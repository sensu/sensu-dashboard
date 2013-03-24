namespace 'SensuDashboard.Views.Checks', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'checks/index'

    initialize: ->
      @autocomplete_view = new SensuDashboard.Views.AutoCompleteField()
      @subview = new exports.List({
        collection: @collection
        autocomplete_view: @autocomplete_view
      })
      @render()

    render: ->
      @$el.html(@template(checks: @collection))
      @assign(@subview, '#checks_container')
      $('#filter').html(@autocomplete_view.render().el)
      this
