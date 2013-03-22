namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Clients extends SensuDashboard.Collections.Base
    model: SensuDashboard.Models.Client,
    url: '/clients'

    comparator: (event) ->
      event.get('name')

    getSelected: ->
      @where(selected: true)

    toggleSelected: ->
      selected = true
      selected = false if @getSelected().length == @length
      @each (client) ->
        client.set(selected: selected)

    getSilenced: ->
      @where(silenced: true)

    getUnsilenced: ->
      @where(silenced: false)

    getSelectedSilenced: ->
      @where(silenced: true, selected: true)

    getSelectedUnsilenced: ->
      @where(silenced: false, selected: true)

    selectAll: ->
      @each (client) ->
        client.set(selected: true)

    selectNone: ->
      @each (client) ->
        client.set(selected: false)

    selectSilenced: ->
      clients = @getSilenced()
      clients_selected = @getSelectedSilenced()
      for client in clients
        selected = true
        selected = false if clients_selected.length == clients.length
        client.set(selected: selected)

    selectUnsilenced: ->
      clients = @getUnsilenced()
      clients_selected = @getSelectedUnsilenced()
      for client in clients
        selected = true
        selected = false if clients_selected.length == clients.length
        client.set(selected: selected)

    silenceSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for client in @getSelected()
        client.silence
          success: (model, response, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback

    unsilenceSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for client in @getSelected()
        client.unsilence
          success: (model, xhr, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback
