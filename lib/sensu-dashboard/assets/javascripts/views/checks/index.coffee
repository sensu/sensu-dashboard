namespace "SensuDashboard.Views.Checks", (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    name: "checks/index"

    events:
      "click #toggle-checkboxes": "toggleSelected"
      "click #select-all": "selectAll"
      "click #select-none": "selectNone"

    initialize: ->
      @autocomplete_view = new SensuDashboard.Views.AutoCompleteField()
      @subview = new exports.List({
        collection: @collection
        autocomplete_view: @autocomplete_view
      })

    render: ->
      @$el.html(@template(checks: @collection))
      @assign(@subview, "#checks_container")
      @$el.find("#filter").html(@autocomplete_view.render().el)
      this

    toggleSelected: ->
      @collection.toggleSelected()

    selectAll: ->
      @collection.selectAll()

    selectNone: ->
      @collection.selectNone()