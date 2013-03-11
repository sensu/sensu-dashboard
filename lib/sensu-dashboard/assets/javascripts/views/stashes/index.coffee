namespace 'SensuDashboard.Views.Stashes', (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    name: 'stashes/index'

    events:
      'click #toggle-checkboxes': 'toggleSelected'
      'click #select-all': 'selectAll'
      'click #select-none': 'selectNone'
      'click #remove-selected': 'removeSelected'

    initialize: ->
      @stashes_view = new exports.List(collection: @collection)
      @autocomplete_view = new SensuDashboard.Views.AutoCompleteField()
      @counts_subview = new SensuDashboard.Views.Stashes.Counts(collection: @collection)
      @stashes_view = new exports.List({
        collection: @collection
        autocomplete_view: @autocomplete_view
      })

    render: ->
      @$el.html(@template(stashes: @collection))
      @assign(@counts_subview, '#counts')
      @assign(@stashes_view, '#stashes_container')
      $('#filter').html(@autocomplete_view.render().el)
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
