namespace "SensuDashboard.Views", (exports) ->

  class exports.Modal extends SensuDashboard.Views.Base

    tagName: "div"

    className: "modal hide fade"

    attributes:
      tabindex: "-1"
      role: "dialog"

    initialize: ->
      @template = HandlebarsTemplates[@options.name || "modal"]
      @$el.on("hidden", => @remove())
      @render()

    render: ->
      @$el.html(@template(@model || {}))
      @$el.appendTo("body")
      @$el.modal("show")

    remove: ->
      @$el.modal("hide")
      super
