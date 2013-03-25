namespace 'SensuDashboard.Models', (exports) ->

  class exports.Client extends Backbone.Model

    defaults:
      name: null
      address: null
      subscriptions: []
      timestamp: 0

    idAttribute: 'name'

    initialize: ->
      @set(silence_path: 'silence/'+@get('name'))
      @listenTo(SensuDashboard.Stashes, 'reset', @setSilencing)
      @listenTo(SensuDashboard.Stashes, 'add', @setSilencing)
      @listenTo(SensuDashboard.Stashes, 'remove', @setSilencing)
      @setSilencing()

    setSilencing: ->
      silenced = false
      silenced = true if SensuDashboard.Stashes.get(@get('silence_path'))
      if @get('silenced') != silenced
        @set(silenced: silenced)

    silence: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      stash = SensuDashboard.Stashes.create
        path: @get('silence_path')
        content: { timestamp: Math.round(new Date().getTime() / 1000) },
        success: (model, response, opts) =>
          @successCallback.apply(this, [this, response, opts]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback


    unsilence: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      stash = SensuDashboard.Stashes.get(@get('silence_path'))
      if stash
        stash.destroy
          success: (model, response, opts) =>
            @successCallback.apply(this, [this, response, opts]) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback
      else
        @errorCallback.apply(this, [this]) if @errorCallback
