namespace 'SensuDashboard.Views.Clients', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'clients/index'

    events:
      'click #toggle-checkboxes': 'toggleSelected'
      'click #select-all': 'selectAll'
      'click #select-none': 'selectNone'
      'click #silence-selected': 'unsilenceSelected'
      'click #unsilence-selected': 'unsilenceSelected'

    initialize: ->
      @subview = new exports.List(collection: @collection)
      @render()

    render: ->
      @$el.html(@template({ clients: @collection }))
      @assign(@subview, '#clients_container')
      this

    toggleSelected: ->
      @collection.toggleSelected()

    selectAll: ->
      @collection.selectAll()

    selectNone: ->
      @collection.selectNone()

    selectSilenced: ->

    selectUnsilenced: ->

    silenceSelected: ->
      @collection.silenceSelected()

    unsilenceSelected: ->
      @collection.unsilenceSelected()
