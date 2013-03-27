namespace "SensuDashboard.Views", (exports) ->

  class exports.Base extends Backbone.View

    template: (args) ->
      tmpl = HandlebarsTemplates[@name]
      tmpl(args) if tmpl

    assign: (view, selector) ->
      view.setElement(@$(selector)).render()

    dispose: ->
      @remove()
      @off()
      @model.off(null, null , @) if @model
      @collection.off(null, null, @) if @collection
