namespace 'SensuDashboard.Views.Info', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'info/index'

    initialize: ->
      @listenTo(@model, 'destroy', @render)
      @listenTo(@model, 'change', @render)
      @render()

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this
