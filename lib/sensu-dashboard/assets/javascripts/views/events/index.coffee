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
      'click #select-silenced-clients': 'selectSilencedClients'
      'click #select-unsilenced-clients': 'selectUnsilencedClients'
      'click #select-silenced-checks': 'selectSilencedChecks'
      'click #select-unsilenced-checks': 'selectUnsilencedChecks'
      'click #resolve-selected': 'resolveSelected'
      'click #silence-selected-clients': 'silenceSelectedClients'
      'click #silence-selected-checks': 'silenceSelectedChecks'
      'click #unsilence-selected-clients': 'unsilenceSelectedClients'
      'click #unsilence-selected-checks': 'unsilenceSelectedChecks'

    initialize: ->
      @events_collection = @model.get('events')
      @counts_subview = new SensuDashboard.Views.Events.Counts(model: @model)
      @list_subview = new SensuDashboard.Views.Events.List(collection: @events_collection)
      @render()

    render: ->
      @$el.html(@template())
      @assign(@counts_subview, '#counts')
      @assign(@list_subview, '#list')
      return this

    toggleSelected: ->
      @events_collection.toggleSelected()

    selectAll: ->
      @events_collection.selectAll()

    selectNone: ->
      @events_collection.selectNone()

    selectCritical: ->
      @events_collection.selectCritical()

    selectUnknown: ->
      @events_collection.selectUnknown()

    selectWarning: ->
      @events_collection.selectWarning()

    selectSilencedClients: ->
      @events_collection.selectSilencedClients()

    selectUnsilencedClients: ->
      @events_collection.selectUnsilencedClients()

    selectSilencedChecks: ->
      @events_collection.selectSilenced()

    selectUnsilencedChecks: ->
      @events_collection.selectUnsilenced()

    resolveSelected: ->
      @events_collection.resolveSelected
        success: ->
          console.log 'resolved events' # TODO: show this visually
        error: (model, xhr, opts) ->
          console.log 'failed to resolve event'
          console.log model

    silenceSelectedClients: ->
      @events_collection.silenceSelectedClients
        success: ->
          console.log 'silenced clients' # TODO: show this visually
        error: (model, xhr, opts) ->
          console.log 'failed to silence clients'
          console.log model

    silenceSelectedChecks: ->
      @events_collection.silenceSelectedChecks
        success: ->
          console.log 'silenced checks' # TODO: show this visually
        error: (model, xhr, opts) ->
          console.log 'failed to silence checks'
          console.log model

    unsilenceSelectedClients: ->
      @events_collection.unsilenceSelectedClients
        success:
          console.log 'unsilenced clients' # TODO: show this visually
        error: (model, xhr, opts) ->
          console.log 'failed to unsilence clients'
          console.log model

    unsilenceSelectedChecks: ->
      @events_collection.unsilenceSelectedChecks
        success:
          console.log 'unsilenced checks' # TODO: show this visually
        error: (model, xhr, opts) ->
          console.log 'failed to unsilence check'
          console.log model
