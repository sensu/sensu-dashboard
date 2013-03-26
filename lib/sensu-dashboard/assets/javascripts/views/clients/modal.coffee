namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.Modal extends SensuDashboard.Views.Modal

    name: 'clients/modal'

    events:
      'click #silence_client': 'silenceClient'
      'click #remove_client': 'removeClient'

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
        @model.unsilence
          success: (model) ->
            client_name = model.get('name')
            toastr.success('Un-silenced client ' + client_name + '.'
              , 'Success!'
              , { positionClass: 'toast-bottom-right' })
          error: (model) ->
            client_name = model.get('name')
            toastr.error('Error un-silencing client ' + client_name + '. ' +
              'The client may already be un-sileneced or Sensu API is down.'
              , 'Un-silencing Error!'
              , { positionClass: 'toast-bottom-right' })
      else
        icon.removeClass('icon-volume-up').addClass('icon-spinner icon-spin')
        text.html('Silencing...')
        @model.silence
          success: (model) ->
            client_name = model.get('name')
            toastr.success('Silenced client ' + client_name + '.'
              , 'Success!'
              , { positionClass: 'toast-bottom-right' })
          error: (model, xhr, opts) ->
            client_name = model.get('name')
            toastr.error('Error silencing client ' + client_name + '.'
              , 'Silencing Error!'
              , { positionClass: 'toast-bottom-right' })

    removeClient: (ev) ->
      tag_name = $(ev.target).prop('tagName')
      if tag_name == 'SPAN' || tag_name == 'I'
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find('i').first()
      text = parent.find('span').first()
      icon.removeClass('icon-remove').addClass('icon-spinner icon-spin')
      text.html('Removing...')
      @model.remove
        success: (model) ->
          toastr.success('Removed client ' + model.get('name') + '.'
            , 'Success!'
            , { positionClass: 'toast-bottom-right' })
        error: (model) ->
          toastr.error('Error removing client ' + model.get('name') + '. ' +
            'The client may have already been removed or Sensu API is down.'
            , 'Removal Error!'
            , { positionClass: 'toast-bottom-right' })
