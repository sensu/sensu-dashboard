namespace 'SensuDashboard.Views.Clients', (exports) ->
  
  class exports.Counts extends SensuDashboard.Views.Base

    name: 'clients/counts'

    initialize: (collection) ->
      @listenTo(@collection, 'all', @render)

    render: ->
      template_data = { count: @collection.models.length }
      @$el.html(@template(template_data))
      this
