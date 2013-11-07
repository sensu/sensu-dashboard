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
      console.log("hi")
      $.ajax
        type: "POST"
        url: "http://sensu-master.edtd.net:4567/check/request"
        data:
          check: "port_http"