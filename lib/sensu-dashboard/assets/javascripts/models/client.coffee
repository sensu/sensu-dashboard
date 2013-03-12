namespace 'SensuDashboard.Models', (exports) ->

  class exports.Client extends Backbone.Model

    defaults:
      name: null
      address: null
      subscriptions: []
      timestamp: 0
      selected: false

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
      stash = new SensuDashboard.Models.Stash
        id: @get('silence_path')
        path: @get('silence_path')
        keys: [ new Date().toUTCString() ]
      stash.url = SensuDashboard.Stashes.url+'/'+@get('silence_path')
      stash.save {},
        success: (model, response, opts) =>
          SensuDashboard.Stashes.add(model)
          @successCallback.apply(this, [model, response, opts]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback

    unsilence: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      stash = SensuDashboard.Stashes.get(@get('silence_path'))
      if stash
        stash.destroy
          url: SensuDashboard.Stashes.url+'/'+@get('silence_path')
          success: (model, response, opts) =>
            @successCallback.apply(this, [model, response, opts]) if @successCallback

          error: (model, xhr, opts) =>
            @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback
      else
        @successCallback.apply(this, [this]) if @successCallback
