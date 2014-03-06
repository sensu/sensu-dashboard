namespace "SensuDashboard.Views.Events", (exports) ->

  class exports.Modal extends SensuDashboard.Views.Modal

    name: "events/modal"

    events:
      "click #silence_client": "silenceClient"
      "click #silence_check": "silenceCheck"
      "click #resolve_check": "resolveCheck"

    initialize: ->
      @$el.on("hidden", => @remove())
      @event = @options.event
      @client = @options.client
      @listenTo(@event, "change", @render)
      @listenTo(@event, "destroy", @remove)
      @listenTo(@client, "change", @render)
      @listenTo(@client, "destroy", @remove)
      @render()

    render: ->
      template_data =
        event: @event.toJSON()
        client: @client.toJSON()
      if @$el.html() == ""
        @$el.html(@template(template_data))
        @$el.appendTo("body")
        @$el.modal("show")
      else
        @$el.html(@template(template_data))

    silenceClient: (ev) ->
      tag_name = $(ev.target).prop("tagName")
      if tag_name == "SPAN" || tag_name == "I"
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find("i").first()
      text = parent.find("span").first()
      expire_time = parseInt($("#silence_client_expire").val(), 10)
      if @client.get("silenced")
        icon.removeClass("icon-volume-off").addClass("icon-spinner icon-spin")
        text.html("Un-silencing...")
        @client.unsilence
          success: (model) ->
            client_name = model.get("name")
            toastr.success("Un-silenced client #{client_name}."
              , "Success!"
              , { positionClass: "toast-bottom-right" })
          error: (model) ->
            client_name = model.get("name")
            toastr.error("Error un-silencing client #{client_name}.
              The client may already be un-sileneced or Sensu API is down."
              , "Un-silencing Error!"
              , { positionClass: "toast-bottom-right" })
      else
        icon.removeClass("icon-volume-up").addClass("icon-spinner icon-spin")
        text.html("Silencing...")
        @client.silence
          expire_time: expire_time
          success: (model) ->
            client_name = model.get("name")
            toastr.success("Silenced client #{client_name}."
              , "Success!"
              , { positionClass: "toast-bottom-right" })
          error: (model, xhr, opts) ->
            client_name = model.get("name")
            toastr.error("Error silencing client #{client_name}."
              , "Silencing Error!"
              , { positionClass: "toast-bottom-right" })

    silenceCheck: (ev) ->
      tag_name = $(ev.target).prop("tagName")
      if tag_name == "SPAN" || tag_name == "I"
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find("i").first()
      text = parent.find("span").first()
      expire_time = parseInt($("#silence_check_expire").val(), 10)
      if @event.get("silenced")
        icon.removeClass("icon-volume-off").addClass("icon-spinner icon-spin")
        text.html("Un-silencing...")
        @event.unsilence
          success: (model) ->
            check_name = model.get("check")
            toastr.success("Un-silenced check #{check_name}."
              , "Success!"
              , { positionClass: "toast-bottom-right" })
          error: (model) ->
            check_name = model.get("check")
            toastr.error("Error un-silencing check #{check_name}.
              The check may already be un-sileneced or Sensu API is down."
              , "Un-silencing Error!"
                , { positionClass: "toast-bottom-right" })
      else
        icon.removeClass("icon-volume-up").addClass("icon-spinner icon-spin")
        text.html("Silencing...")
        @event.silence
          expire_time: expire_time
          success: (model) ->
            check_name = model.get("check")
            toastr.success("Silenced check #{check_name}."
              , "Success!"
              , { positionClass: "toast-bottom-right" })
          error: (model) ->
            check_name = model.get("check")
            toastr.error("Error silencing check #{check_name}."
              , "Silencing Error!"
              , { positionClass: "toast-bottom-right" })

    resolveCheck: (ev) ->
      tag_name = $(ev.target).prop("tagName")
      if tag_name == "SPAN" || tag_name == "I"
        parent = $(ev.target).parent()
      else
        parent = $(ev.target)
      icon = parent.find("i").first()
      text = parent.find("span").first()
      icon.removeClass("icon-ok").addClass("icon-spinner icon-spin")
      text.html("Resolving...")
      @event.resolve
        success: (model) ->
          event_name = "#{model.get("client")}_#{model.get("check")}"
          toastr.success("Resolved event #{event_name}."
            , "Success!"
            , { positionClass: "toast-bottom-right" })
        error: (model) ->
          event_name = "#{model.get("client")}_#{model.get("check")}"
          toastr.error("Error resolving event #{event_name}. Is Sensu API running?"
            , "Resolving Error"
            , { positionClass: "toast-bottom-right" })
