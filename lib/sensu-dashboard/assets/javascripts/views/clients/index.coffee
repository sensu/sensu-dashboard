namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'clients/index'

    initialize: ->
      @subview = new exports.List(collection: @collection)
      @render()

    render: ->
      @$el.html(@template({ clients: @collection }))
      @assign(@subview, '#clients_container')
      this
