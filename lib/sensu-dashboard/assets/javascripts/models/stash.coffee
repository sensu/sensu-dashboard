namespace "SensuDashboard.Models", (exports) ->

  class exports.Stash extends Backbone.Model

    defaults:
      path: "silence"
      content: {}
      expire: 300

    idAttribute: "path"

    isNew: =>
      !_.contains(SensuDashboard.Stashes.models, this)

    create: (attributes, options) =>
      options ||= {}
      options.wait = true
      Backbone.create(attributes, options)

    sync: (method, model, options) =>
      options ||= {}
      if method == "delete"
        options.url = "#{SensuDashboard.Stashes.url}/#{model.get("path")}"
      Backbone.sync(method, model, options)

    remove: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      @destroy
        wait: true
        success: (model, response, opts) =>
          @successCallback.apply(this, [model, response, opts]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback

    updateStash: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      stash = SensuDashboard.Stashes.create({
        path: options.silence_path
        expire: options.expire_time
        content: { timestamp: Math.round(new Date().getTime() / 1000) }}, {
        success: (model, response, opts) =>
          @successCallback.apply(this, [this, response]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback})
