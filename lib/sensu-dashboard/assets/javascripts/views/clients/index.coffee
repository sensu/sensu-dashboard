namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'clients/index'

    events:
      'click #toggle-checkboxes': 'toggleSelected'
      'click #select-all': 'selectAll'
      'click #select-none': 'selectNone'
      'click #select-silenced': 'selectSilenced'
      'click #select-unsilenced': 'selectUnsilenced'
      'click #silence-selected-clients': 'silenceSelected'
      'click #unsilence-selected-clients': 'unsilenceSelected'

    initialize: ->
      @subview = new exports.List(collection: @collection)
      @render()

    render: ->
      @$el.html(@template(clients: @collection))
      @assign(@subview, '#clients_container')
      this

    toggleSelected: ->
      @collection.toggleSelected()

    selectAll: ->
      @collection.selectAll()

    selectNone: ->
      @collection.selectNone()

    selectSilenced: ->
      @collection.selectSilenced()

    selectUnsilenced: ->
      @collection.selectUnsilenced()

    silenceSelected: ->
      @collection.silenceSelected
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

    unsilenceSelected: ->
      @collection.unsilenceSelected
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
