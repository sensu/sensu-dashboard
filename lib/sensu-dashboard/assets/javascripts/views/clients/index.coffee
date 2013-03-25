namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

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
      @counts_subview = new SensuDashboard.Views.Clients.Counts(collection: @collection)
      @autocomplete_view = new SensuDashboard.Views.AutoCompleteField()
      @subview = new exports.List({
        collection: @collection
        autocomplete_view: @autocomplete_view
      })

    render: ->
      @$el.html(@template(clients: @collection))
      @assign(@counts_subview, '#counts')
      @assign(@subview, '#clients_container')
      @$el.find('#filter').html(@autocomplete_view.render().el)
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
