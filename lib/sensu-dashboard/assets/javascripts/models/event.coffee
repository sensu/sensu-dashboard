namespace 'SensuDashboard.Models', (exports) ->

  class exports.Event extends Backbone.Model

    defaults:
      client: null
      check: null
      occurrences: 0
      output: null
      status: 3
      flapping: false
      issued: '0000-00-00T00:00:00Z'
      selected: false
      silenced: false
      client_silenced: false

    initialize: ->
      @set(id: @get('client')+'/'+@get('check'))
      @setOutputIfEmpty(@get('output'))
      @setStatusName(@get('status'))
      @set
        url: '/events/'+@get('id')
        client_silence_path: 'silence/'+@get('client')
        silence_path: 'silence/'+@get('id')
      @listenTo(SensuDashboard.Stashes, 'reset', @setSilencing)
      @listenTo(SensuDashboard.Stashes, 'add', @setSilencing)
      @listenTo(SensuDashboard.Stashes, 'remove', @setSilencing)
      @setSilencing()

    setSilencing: ->
      silenced = false
      client_silenced = false
      silenced = true if SensuDashboard.Stashes.get(@get('silence_path'))
      client_silenced = true if SensuDashboard.Stashes.get(@get('client_silence_path'))
      if @get('silenced') != silenced || @get('client_silenced') != client_silenced
        @set
          silenced: silenced
          client_silenced: client_silenced

    setOutputIfEmpty: (output) ->
      if output == ''
        @set(output: 'nil output')

    setStatusName: (status) ->
      switch status
        when 1 then @set(status_name: 'warning')
        when 2 then @set(status_name: 'critical')
        else @set(status_name: 'unknown')

    resolve: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      @destroy
        url: @get('url')
        success: (model, response, opts) =>
          @successCallback.apply(this, [model, response, opts]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback

    silence: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      stash = new SensuDashboard.Models.Stash
        path: @get('silence_path')
        timestamp: Math.round(new Date().getTime() / 1000)
      stash.url = SensuDashboard.Stashes.url+'/'+@get('silence_path')
      stash.save {},
        success: (model, response, opts) =>
          delete model.attributes.issued
          SensuDashboard.Stashes.add(model)
          @successCallback.apply(this, [this, response, opts]) if @successCallback
        error: (model, xhr, opts) =>
          @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback

    unsilence: (options = {}) =>
      @successCallback = options.success
      @errorCallback = options.error
      stash = SensuDashboard.Stashes.get(@get('silence_path'))
      if stash
        stash.destroy
          url: SensuDashboard.Stashes.url+'/'+@get('silence_path')
          success: (model, response, opts) =>
            @successCallback.apply(this, [this, response, opts]) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.apply(this, [this, xhr, opts]) if @errorCallback
      else
        @errorCallback.apply(this, [this]) if @errorCallback
