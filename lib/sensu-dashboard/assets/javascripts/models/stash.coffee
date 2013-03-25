namespace 'SensuDashboard.Models', (exports) ->

  class exports.Stash extends Backbone.Model

    defaults:
      path: 'silence'
      content: {}

    idAttribute: 'path'

    isNew: =>
      !_.contains(SensuDashboard.Stashes.models, this)

    create: (attributes, options) =>
      options ||= {}
      options.wait = true
      Backbone.create(attributes, options)

    remove: (options = {}) =>
      @destroy(options)
