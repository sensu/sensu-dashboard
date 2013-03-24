namespace 'SensuDashboard.Models', (exports) ->

  class exports.Stash extends Backbone.Model

    defaults:
      path: 'silence'

    idAttribute: 'path'

    remove: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      @destroy
        success: (model, response, opts) =>
          @successCallback.apply(this, [model, response, opts]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback
