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
      @collection.removeSelected
        success: (model) ->
          stash_name = model.get('path')
          toastr.success('Removed stash ' + stash_name + '.'
            , 'Success!'
            , { positionClass: 'toast-bottom-right' })
        error: (model) ->
          stash_name = model.get('path')
          toastr.error('Error removing stash ' + stash_name + '. ' +
            'The stash may already be removed or Sensu API is down.'
            , 'Removal Error!'
            , { positionClass: 'toast-bottom-right' })
