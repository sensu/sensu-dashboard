namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.Modal extends SensuDashboard.Views.Modal

    name: 'stashes/modal'

    events:
      'click #remove_stash': 'removeStash'

    initialize: ->
      @$el.on('hidden', => @remove())
      @listenTo(@model, 'change', @render)
      @listenTo(@model, 'destroy', @remove)
      @render()

    render: ->
      template_data = { keys: @model.toJSON() }
      if @$el.html() == ''
        @$el.html(@template(template_data))
        @$el.appendTo('body')
        @$el.modal('show')
      else
        @$el.html(@template(template_data))

    removeStash: (ev) ->
      tag_name = $(ev.target).prop('tagName')
      if tag_name == 'SPAN' || tag_name == 'I'
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find('i').first()
      text = parent.find('span').first()
      icon.removeClass('icon-volume-off').addClass('icon-spinner icon-spin')
      text.html('Removing...')
      @model.remove()
