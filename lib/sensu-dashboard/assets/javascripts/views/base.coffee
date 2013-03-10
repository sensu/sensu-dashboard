namespace 'SensuDashboard.Views', (exports) ->

  class exports.Base extends Backbone.View

    assign: (view, selector) ->
      view.setElement(@$(selector)).render()
