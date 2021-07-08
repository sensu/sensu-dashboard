namespace "SensuDashboard.Views.Checks", (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: "checks/list_item"

    className: ->
      @model.get("name")

    events:
      "click input[type=checkbox]": "toggleSelect"

    toggleSelect: ->
      @model.set(selected: !@model.get("selected"))

    render: ->
      @$el.html(@template(@presenter()))
      this

    presenter: ->
      _.extend(@model.toJSON(), {
        standalone: @model.get("standalone") || "false"
      })
