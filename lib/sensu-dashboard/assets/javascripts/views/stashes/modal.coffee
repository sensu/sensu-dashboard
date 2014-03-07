namespace "SensuDashboard.Views.Stashes", (exports) ->

  class exports.Modal extends SensuDashboard.Views.Modal

    name: "stashes/modal"

    events:
      "click #update_stash": "updateStash"
      "click #remove_stash": "removeStash"

    initialize: ->
      @$el.on("hidden", => @remove())
      @listenTo(@model, "change", @render)
      @listenTo(@model, "destroy", @remove)
      @render()

    render: ->
      template_data = @model.toJSON()
      if @$el.html() == ""
        @$el.html(@template(template_data))
        @$el.appendTo("body")
        @$el.modal("show")
      else
        @$el.html(@template(template_data))

    removeStash: (ev) ->
      tag_name = $(ev.target).prop("tagName")
      if tag_name == "SPAN" || tag_name == "I"
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find("i").first()
      text = parent.find("span").first()
      icon.removeClass("icon-remove").addClass("icon-spinner icon-spin")
      text.html("Removing...")
      @model.remove
        success: (model) ->
          stash_name = model.get("path")
          toastr.success("Removed stash #{stash_name}."
            , "Success!"
            , { positionClass: "toast-bottom-right" })
        error: (model) ->
          stash_name = model.get("path")
          toastr.error("Error removing stash #{stash_name}.
            The stash may already be removed or Sensu API is down."
            , "Removal Error!"
            , { positionClass: "toast-bottom-right" })

    updateStash: (ev) ->
      tag_name = $(ev.target).prop("tagName")
      if tag_name == "SPAN" || tag_name == "I"
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      text = parent.find("span").first()
      silence_path = $("#silence_path").val()
      expire_time = parseInt($("#stash_expire").val(), 10)
      text.html("Updating...")
      @model.updateStash
        expire_time: expire_time
        silence_path: silence_path
        success: (model) ->
          toastr.success("Updated stash #{silence_path}."
            , "Success!"
            , { positionClass: "toast-bottom-right" })
        error: (model, xhr, opts) ->
          toastr.error("Error updating stash#{silence_path}."
            , "Updating Error!"
            , { positionClass: "toast-bottom-right" })
