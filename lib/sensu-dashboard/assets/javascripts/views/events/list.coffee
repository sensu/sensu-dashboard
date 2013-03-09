namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.List extends SensuDashboard.Views.Base

    name: 'events/list'

    initialize: (collection) ->
      @template = HandlebarsTemplates[@name]
      _.bindAll(this, 'addOne')
      @collection = collection
      @listenTo(@collection, 'all', @render)

    addOne: (event) ->
      item_subview = new SensuDashboard.Views.Events.Item({ model: event })
      @assign(item_subview, 'tbody')

    addAll: ->
      @collection.each(@addOne)

    render: ->
      @$el.html(@template(@collection.toJSON()))
      @addAll()
      return this

    # showEventDetails: (ev) ->
    #   data_id = $(ev.target).parents('tr').first().attr('data-id')
    #   current_event = SensuDashboard.Events.get(data_id)
    #   current_client = SensuDashboard.Clients.get(current_event.attributes.client)
    #   SensuDashboard.EventsMetadata.set
    #     current_event: current_event
    #     current_client: current_client
    #   $('#event_modal').modal()

    # toggleSelect: ->
    #   @model.set({ selected: true })
