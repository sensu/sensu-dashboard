namespace 'SensuDashboard', (exports) ->

  class Application

    constructor: ->
      #@errorView = new SensuDashboard.Views.AppStateView("error")

      bootstrapper = new SensuDashboard.Bootstrapper
        success: =>
          @boot()

        error: =>
          console.log("Bootstrap Error")
          $("#initial-loading-indicator").remove()
          # @errorView.render()

      #bootstrapper.fetch()

    boot: ->
      #SensuDashboard.keyboardManager = new KeyboardManager()

      $("#initial-loading-indicator").remove()
      #@errorView.destroy()
      #$("#app-content").css({display: "block"})

      #@appNavigation = new SensuDashboard.Views.AppNavigationView({
      #  el: document.getElementById("app-navigation")
      #})
      #@appNavigation.render()

      #match = Backbone.history.start { pushState: true }

      # Show "Events" if no route already
      #SensuDashboard.stateManager.transitionTo("events") unless match

  exports.App = new Application() # Initialize app

