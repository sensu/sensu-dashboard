namespace 'SensuDashboard.Views.Events', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'events/index'

    events:
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
