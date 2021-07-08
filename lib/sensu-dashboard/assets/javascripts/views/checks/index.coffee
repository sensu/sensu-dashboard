namespace "SensuDashboard.Views.Checks", (exports) ->

  class exports.Index extends SensuDashboard.Views.Base

    name: "checks/index"

    events:
      "click #toggle-checkboxes": "toggleSelected"
      "click #select-all": "selectAll"
      "click #select-none": "selectNone"
      "click #request-selected-checks": "requestSelected"

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

    requestSelected: ->
      @collection.requestSelected
        success: (model) ->
          check_name = model.get('name')
          toastr.success("Check #{check_name} requested", "Success!", { positionClass: "toast-bottom-right" })
        error: (model) ->
          check_name = model.get('name')
          toastr.error("Error requesting check #{check_name}.", "Request Check Error!", { positionClass: "toast-bottom-right" })