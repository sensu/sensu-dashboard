namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Item extends SensuDashboard.Views.Base

    name: 'events/item'

    tagName: 'tr'

    className: ->
      @model.get('status_name')

    events:
      'click td': 'showDetails'
      'click input[type=checkbox]': 'toggleSelect'

    initialize: ->
      @template = HandlebarsTemplates[@name]
      @listenTo(@model, 'change', @render)
      @listenTo(@model, 'destroy', @remove)

    render: ->
      @$el.html(@template(@model.toJSON()))
      return this

    toggleSelect: ->
      @model.set({ selected: !@model.get('selected') })

    showDetails: ->
      new SensuDashboard.Views.Modal
        name: 'events/modal'
        model:
          event: @model.toJSON()
          client: SensuDashboard.Clients.get(@model.get('client')).toJSON()
          stashes: SensuDashboard.Stashes.toJSON()
