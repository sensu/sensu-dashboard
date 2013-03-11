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
      'click #silence-selected-checks': 'silenceSelectedChecks'
      'click #unsilence-selected-checks': 'unsilenceSelectedChecks'

    initialize: ->
      @counts_subview = new SensuDashboard.Views.Events.Counts(@model)
      @list_subview = new SensuDashboard.Views.Events.List(collection: @model.get('events'))
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

    selectSilenced: ->

    selectUnsilenced: ->

    resolveSelected: ->
      @model.get('events').resolveSelected
        success: ->
          console.log 'resolved events' # TODO: show this visually
        error: (model, xhr, opts) ->
          console.log 'failed to resolve event'
          console.log model

    silenceSelectedChecks: ->
      @model.get('events').silenceSelected
        success: ->
          console.log 'silenced events'
        error: (model, xhr, opts) ->
          console.log 'failed to silence event'
          console.log model

    unsilenceSelectedChecks: ->
      @model.get('events').unsilenceSelected
        success:
          console.log 'unsilenced events'
        error: (model, xhr, opts) ->
          console.log 'failed to unsilence event'
          console.log model
