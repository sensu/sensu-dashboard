namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends Backbone.View

    el: $('#main')

    name: 'events/index'

    events:
      'click td[data-controls-modal]': 'showEventDetails'
      'click button#resolve_check': 'resolveEvent'
      'click button#silence_client': 'silenceClient'
      'click button#silence_check': 'silenceCheck'

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
      data_id = $(ev.target).parents('tr').first().attr('data-id')
      current_event = SensuDashboard.Events.get(data_id)
      current_client = SensuDashboard.Clients.get(current_event.attributes.client)
      SensuDashboard.EventsMetadata.set
        current_event: current_event
        current_client: current_client
      $('#event_modal').modal()

    resolveEvent: (ev) ->
      tag_name = $(ev.target).prop('tagName')
      if tag_name == 'SPAN' || tag_name == 'I'
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find('i').first()
      text = parent.find('span').first()
      icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')
      text.html('Resolving...')

    silenceClient: (ev) ->
      tag_name = $(ev.target).prop('tagName')
      if tag_name == 'SPAN' || tag_name == 'I'
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find('i').first()
      text = parent.find('span').first()
      icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')

      client_name = SensuDashboard.EventsMetadata.get('current_client').attributes.name
      stash = SensuDashboard.Stashes.get('silence/'+client_name)
      if stash
        text.html('Un-silencing...')
        options =
          url: SensuDashboard.Stashes.url+'/'+stash.get('id')
        stash.destroy(options)
      else
        text.html('Silencing...')
        stash = new SensuDashboard.Models.Stash
          id: 'silence/'+client_name
          path: 'silence/'+client_name
          keys: [ new Date().toUTCString() ]
        stash.url = SensuDashboard.Stashes.url+'/silence/'+client_name
        stash.save {},
          success: (model, response, options) ->
            SensuDashboard.Stashes.add(model)
          error: (model, xhr, options) ->
            console.log model
            console.log xhr
            console.log options

    silenceCheck: (ev) ->
