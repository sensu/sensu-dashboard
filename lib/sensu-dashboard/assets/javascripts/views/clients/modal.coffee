namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.Modal extends SensuDashboard.Views.Modal

    name: 'clients/modal'

    events:
      'click #silence_client': 'silenceClient'

    initialize: ->
      @$el.on('hidden', => @remove())
      @listenTo(@model, 'change', @render)
      @listenTo(@model, 'destroy', @remove)
      @render()

    render: ->
      template_data = @model.toJSON()
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
      if @model.get('silenced')
        icon.removeClass('icon-volume-off').addClass('icon-spinner icon-spin')
        text.html('Un-silencing...')
        @model.unsilence()
      else
        icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')
        text.html('Silencing...')
        @model.silence()
