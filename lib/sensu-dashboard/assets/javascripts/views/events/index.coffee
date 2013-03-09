namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'events/index'

    events:
      #'click td[data-controls-modal]': 'showEventDetails'
      #'click #resolve_check': 'resolveEvent'
      #'click #silence_client': 'silenceClient'
      #'click #silence_check': 'silenceCheck'
      'click #toggle-checkboxes': 'toggleSelected'
      'click #select-all': 'selectAll'
      'click #select-none': 'selectNone'
      'click #select-critical': 'selectCritical'
      'click #select-unknown': 'selectUnknown'
      'click #select-warning': 'selectWarning'
      'click #resolve-selected': 'resolveSelected'
      'click #silence-selected': 'unsilenceSelected'
      'click #unsilence-selected': 'unsilenceSelected'

    initialize: (model) ->
      @template = HandlebarsTemplates[@name]
      @model = model
      @counts_subview = new SensuDashboard.Views.Events.Counts(@model)
      @list_subview = new SensuDashboard.Views.Events.List(@model.get('events'))
      @render()

    render: ->
      @$el.html(@template())
      @assign(@counts_subview, '#counts')
      @assign(@list_subview, '#list')
      return this

    toggleSelected: ->
      @model.get('events').toggleSelected()

    selectAll: ->
      @model.get('events').selectAll()

    selectNone: ->
      @model.get('events').selectNone()

    selectCritical: ->
      @model.get('events').selectCritical()

    selectUnknown: ->
      @model.get('events').selectUnknown()

    selectWarning: ->
      @model.get('events').selectWarning()

    resolveSelected: ->
      @model.get('events').resolveSelected()

    silenceSelected: ->
      @model.get('events').silenceSelected()

    unsilenceSelected: ->
      @model.get('events').unsilenceSelected()

    showEventDetails: (ev) ->
      data_id = $(ev.target).parents('tr').first().attr('data-id')
      current_event = SensuDashboard.Events.get(data_id)
      current_client = SensuDashboard.Clients.get(current_event.attributes.client)
      SensuDashboard.EventsMetadata.set
        current_event: current_event
        current_client: current_client
      $('#event_modal').modal()

    # resolveEvent: (ev) ->
    #   tag_name = $(ev.target).prop('tagName')
    #   if tag_name == 'SPAN' || tag_name == 'I'
    #     parent = $(ev.target).parent()
    #   else
    #     parent = $(ev.target)
    #   icon = parent.find('i').first()
    #   text = parent.find('span').first()
    #   icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')
    #   text.html('Resolving...')

    # silenceClient: (ev) ->
    #   tag_name = $(ev.target).prop('tagName')
    #   if tag_name == 'SPAN' || tag_name == 'I'
    #     parent = $(ev.target).parent()
    #   else
    #     parent = $(ev.target)
    #   icon = parent.find('i').first()
    #   text = parent.find('span').first()
    #   icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')

    #   client_name = SensuDashboard.EventsMetadata.get('current_client').attributes.name
    #   stash = SensuDashboard.Stashes.get('silence/'+client_name)
    #   if stash
    #     text.html('Un-silencing...')
    #     options =
    #       url: SensuDashboard.Stashes.url+'/'+stash.get('id')
    #     stash.destroy(options)
    #   else
    #     text.html('Silencing...')
    #     stash = new SensuDashboard.Models.Stash
    #       id: 'silence/'+client_name
    #       path: 'silence/'+client_name
    #       keys: [ new Date().toUTCString() ]
    #     stash.url = SensuDashboard.Stashes.url+'/silence/'+client_name
    #     stash.save {},
    #       success: (model, response, options) ->
    #         SensuDashboard.Stashes.add(model)
    #       error: (model, xhr, options) ->
    #         console.log model
    #         console.log xhr
    #         console.log options

    # silenceCheck: (ev) ->
