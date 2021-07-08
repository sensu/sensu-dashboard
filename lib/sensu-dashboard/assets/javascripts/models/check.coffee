namespace "SensuDashboard.Models", (exports) ->

  class exports.Check extends Backbone.Model

    defaults:
      handlers: ["default"]
      standalone: false
      subscribers: []
      interval: 60

    idAttribute: "name"

    request: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      $.ajax
        type: "POST"
        url: "/check/request"
        contentType: "application/json"
        data:
          JSON.stringify {
            check: this.get("name")
            subscribers: this.get("subscribers")
          }
        success: (data, status, xhr) =>
          @successCallback.call(xhr, this) if @successCallback
        error: (xhr, status, error) =>
          console.log("model")
          console.log(xhr, this)
          @errorCallback.call(xhr, this) if @errorCallback