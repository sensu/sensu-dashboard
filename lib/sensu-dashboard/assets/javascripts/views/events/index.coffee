namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends Backbone.View

    el: $('#main')

    name: 'events/index'

    events:
      'click td[data-controls-modal]': 'showEventDetails'
      'click button#resolve_check': 'resolveEvent'

    initialize: (collection) ->
      @template = HandlebarsTemplates[@name]
      @collection = collection
      @listenTo(collection, 'reset', @render)
      @listenTo(collection, 'change', @render)
      @render()

    addOne: (item) ->


    addAll: ->
      @$el.empty()
      @$el.html(@template(@collection.toJSON()))

    render: ->
      @addAll()
      return this

    showEventDetails: (ev) ->
      data_id = $(ev.target).parent().attr('data-id')
      current_event = SensuDashboard.Events.get(data_id)
      current_client = SensuDashboard.Clients.get(current_event.attributes.client)
      SensuDashboard.EventsMetadata.set
        current_event: current_event
        current_client: current_client
      $('#event_modal').modal()

    resolveEvent: (ev) ->
      data_id = $(ev.target).attr('data-id')

