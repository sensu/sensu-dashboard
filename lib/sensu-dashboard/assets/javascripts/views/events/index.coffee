namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends Backbone.View

    el: $('#main')

    name: 'events/index'

    events:
      'click td[data-controls-modal]': 'showEventDetails'
      'click button#resolve_check': 'resolveEvent'

    initialize: ->
      @template = HandlebarsTemplates[@name]
      @listenTo(SensuDashboard.EventsMetadata, 'reset', @render)
      @listenTo(SensuDashboard.EventsMetadata, 'change', @render)
      @render()

    addOne: (item) ->


    addAll: ->
      @$el.empty()
      @$el.html(@template(SensuDashboard.EventsMetadata.toJSON()))

    render: ->
      @addAll()
      return this

    showEventDetails: (ev) ->
      data_id = $(ev.target).parent().attr('data-id')
      SensuDashboard.EventsMetadata.set
        current_model: SensuDashboard.Events.get(data_id)
      $('#event_modal').modal()

    resolveEvent: (ev) ->
      data_id = $(ev.target).attr('data-id')

