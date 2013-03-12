namespace 'SensuDashboard.Views', (exports) ->

  class exports.ListItem extends SensuDashboard.Views.Base

    tagName: 'tr'

    initialize: ->
      @name = @options.name unless @name
      @listenTo(@model, 'change',  @render)
      @listenTo(@model, 'destroy', @remove)

    render: ->
      @$el.html(@template(@model.toJSON()))
      this
