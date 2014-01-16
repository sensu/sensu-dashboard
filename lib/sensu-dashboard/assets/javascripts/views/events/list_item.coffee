namespace "SensuDashboard.Views.Events", (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: "events/list_item"

    className: ->
      @model.get("status_name")

    events:
      "click td:not(.select)": "showDetails"
      "click input[type=checkbox]": "toggleSelect"

    initialize: ->
      super

    toggleSelect: ->
      @model.set(selected: !@model.get("selected"))

    showDetails: ->
      new SensuDashboard.Views.Events.Modal
        event: @model