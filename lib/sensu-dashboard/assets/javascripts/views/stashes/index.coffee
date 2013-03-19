namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    el: $('#main')

    name: 'stashes/index'

    events:
      'click #toggle-checkboxes': 'toggleSelected'
      'click #select-all': 'selectAll'
      'click #select-none': 'selectNone'
      'click #remove-selected': 'removeSelected'

    initialize: ->
      @stashes_view = new exports.List(collection: @collection)
      @render()

    render: ->
      @$el.html(@template(stashes: @collection))
      @assign(@stashes_view, '#stashes_container')
      this

    toggleSelected: ->
      @collection.toggleSelected()

    selectAll: ->
      @collection.selectAll()

    selectNone: ->
      @collection.selectNone()

    removeSelected: ->
      @collection.removeSelected()
