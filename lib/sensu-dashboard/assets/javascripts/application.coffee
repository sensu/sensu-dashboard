namespace 'SensuDashboard', (exports) ->

  class Application

    constructor: ->
      SensuDashboard.Routes = new SensuDashboard.Router

      bootstrapper = new SensuDashboard.Bootstrapper
        success: =>
          @boot()

        error: =>
          console.log("Bootstrap Error")
          $("#initial-loading-indicator").remove()

    boot: ->
      $("#initial-loading-indicator").remove()

      Backbone.history.start()

  exports.App = new Application() # Initialize app
