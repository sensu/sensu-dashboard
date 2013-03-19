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
      @collection.silenceSelected()

    unsilenceSelected: ->
      @collection.unsilenceSelected()
