namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Modal extends SensuDashboard.Views.Modal

    name: 'events/modal'

    events:
      'click #silence_client': 'silenceClient'
      'click #silence_check': 'silenceCheck'
      'click #resolve_check': 'resolveCheck'

    initialize: ->
      @$el.on('hidden', => @remove())
      @event = @options.event
      @client = @options.client
      @listenTo(@event, 'change', @render)
      @listenTo(@event, 'destroy', @remove)
      @listenTo(@client, 'change', @render)
      @listenTo(@client, 'destroy', @remove)
      @render()

    render: ->
      template_data =
        event: @event.toJSON()
        client: @client.toJSON()
      if @$el.html() == ''
        @$el.html(@template(template_data))
        @$el.appendTo('body')
        @$el.modal('show')
      else
        @$el.html(@template(template_data))

    silenceClient: (ev) ->
      tag_name = $(ev.target).prop('tagName')
      if tag_name == 'SPAN' || tag_name == 'I'
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find('i').first()
      text = parent.find('span').first()
      if @client.get('silenced')
        icon.removeClass('icon-volume-off').addClass('icon-spinner icon-spin')
        text.html('Un-silencing...')
        @client.unsilence()
      else
        icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')
        text.html('Silencing...')
        @client.silence()

    silenceCheck: (ev) ->
      tag_name = $(ev.target).prop('tagName')
      if tag_name == 'SPAN' || tag_name == 'I'
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find('i').first()
      text = parent.find('span').first()
      if @event.get('silenced')
        icon.removeClass('icon-volume-off').addClass('icon-spinner icon-spin')
        text.html('Un-silencing...')
        @event.unsilence()
      else
        icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')
        text.html('Silencing...')
        @event.silence()

    resolveCheck: (ev) ->
      tag_name = $(ev.target).prop('tagName')
      if tag_name == 'SPAN' || tag_name == 'I'
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find('i').first()
      text = parent.find('span').first()
      icon.removeClass('icon-volume-off').addClass('icon-spinner icon-spin')
      text.html('Resolving...')
      @event.resolve()
