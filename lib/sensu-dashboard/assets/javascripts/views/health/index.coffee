namespace 'SensuDashboard.Views.Health', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'health/index'

    initialize: ->
      @listenTo(@model, 'destroy', @render)
      @listenTo(@model, 'change', @render)
      @render()

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this
