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
      @auto_complete = new SensuDashboard.Views.AutoCompleteField({
        sources: [SensuDashboard.Clients, SensuDashboard.Checks]
        results_view: new SensuDashboard.Views.AutoCompleteResults()
      })
      @list_subview = new SensuDashboard.Views.Events.List({
        collection: @events_collection
        autocomplete_view: @auto_complete
      })
      @render()

    render: ->
      @$el.html(@template())
      @assign(@counts_subview, '#counts')
      @assign(@list_subview, '#list')
      $('#filter').html(@auto_complete.render().el)
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
      events_selected = @events_collection.getSelected().length
      @events_collection.selectUnsilenced
        success: ->
          toastr.success('Unsilenced ' + events_selected + ' events'
            , 'Success!'
            , { positionClass: 'toast-bottom-right' })

    resolveSelected: ->
      @events_collection.resolveSelected
        success: (model) ->
          event_name = model.get('client') + '_' + model.get('check')
          toastr.success('Resolved event ' + event_name + '.'
            , 'Success!'
            , { positionClass: 'toast-bottom-right' })
        error: (model) ->
          event_name = model.get('client') + '_' + model.get('check')
          toastr.error('Error resolving event ' + event_name + '. Is Sensu API running?'
            , 'Resolving Error'
            , { positionClass: 'toast-bottom-right' })


    silenceSelectedClients: ->
      @events_collection.silenceSelectedClients
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

    silenceSelectedChecks: ->
      @events_collection.silenceSelectedChecks
        success: (model) ->
          check_name = model.get('check')
          toastr.success('Silenced check ' + check_name + '.'
            , 'Success!'
            , { positionClass: 'toast-bottom-right' })
        error: (model) ->
          check_name = model.get('check')
          toastr.error('Error silencing check ' + check_name + '.'
            , 'Silencing Error!'
            , { positionClass: 'toast-bottom-right' })

    unsilenceSelectedClients: ->
      @events_collection.unsilenceSelectedClients
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

    unsilenceSelectedChecks: ->
      @events_collection.unsilenceSelectedChecks
        success: (model) ->
          check_name = model.get('check')
          toastr.success('Un-silenced check ' + check_name + '.'
            , 'Success!'
            , { positionClass: 'toast-bottom-right' })
        error: (model) ->
          check_name = model.get('check')
          toastr.error('Error un-silencing check ' + check_name + '. ' +
            'The check may already be un-sileneced or Sensu API is down.'
            , 'Un-silencing Error!'
            , { positionClass: 'toast-bottom-right' })
