namespace 'SensuDashboard.Views.Checks', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'checks/index'

    events:
      'click #toggle-checkboxes': 'toggleSelected'
      'click #select-all': 'selectAll'
      'click #select-none': 'selectNone'
      'click #select-silenced': 'selectSilenced'
      'click #select-unsilenced': 'selectUnsilenced'
      'click #silence-selected': 'silenceSelected'
      'click #unsilence-selected': 'unsilenceSelected'

    initialize: ->
      @subview = new exports.List(collection: @collection)
      @render()

    render: ->
      @$el.html(@template(checks: @collection))
      @assign(@subview, '#checks_container')
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

    unsilenceSelected: ->
