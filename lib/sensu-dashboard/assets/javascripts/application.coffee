namespace 'SensuDashboard', (exports) ->

  class Application

    constructor: ->
      $.ajaxSetup(cache: false)

      bootstrapper = new SensuDashboard.Bootstrapper
        success: =>
          @boot()

        error: =>
          new SensuDashboard.Views.Error
          toastr.error("Error during bootstrap. Is Sensu API running?"
            , "Bootstrap Error"
            , { positionClass: 'toast-bottom-right' })

    boot: ->
      Backbone.history.start()

  exports.App = new Application() # Initialize app
