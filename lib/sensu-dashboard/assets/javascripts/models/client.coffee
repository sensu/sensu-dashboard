namespace 'SensuDashboard.Models', (exports) ->

  class exports.Client extends Backbone.Model

    defaults:
      name: null
      address: null
      subscriptions: []
      timestamp: 0
      selected: false

    idAttribute: 'name'

    silence: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      stash_path = 'silence/'+@get('client')
      stash = SensuDashboard.Stashes.get(stash_path)
      if stash
        stash.destroy
          url: SensuDashboard.Stashes.url+'/'+stash.get('id')
          success: (model, response, opts) ->
            @successCallback.call(this)
          error: (model, xhr, opts) ->
            @errorCallback.call(this)
      else
        stash = new SensuDashboard.Models.Stash
          id: stash_path
          path: stash_path
          keys: [ new Date().toUTCString() ]
        stash.url = SensuDashboard.Stashes.url+'/'+stash_path
        stash.save {},
          success: (model, response, opts) ->
            SensuDashboard.Stashes.add(model)
            @successCallback.call(this)
          error: (model, xhr, opts) ->
            @errorCallback.call(this)
