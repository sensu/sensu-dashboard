namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Events extends Backbone.Collection
    model: SensuDashboard.Models.Event,
    url: '/events'

    comparator: (event) ->
      event.get('status_name')

    getSelected: ->
      @where(selected: true)

    getCriticals: ->
      @where(status: 2)

    getUnknowns: ->
      @filter (event) ->
        status = event.get('status')
        return status != 1 && status != 2

    getWarnings: ->
      @where(status: 1)

    getSilenced: ->
      @where(silenced: true)

    getSilencedClients: ->
      @where(client_silenced: true)

    getUnsilenced: ->
      @where(silenced: false)

    getUnsilencedClients: ->
      @where(client_silenced: false)

    getSelectedCriticals: ->
      @where(status: 2, selected: true)

    getSelectedUnknowns: ->
      @filter (event) ->
        status = event.get('status')
        selected = event.get('selected')
        return status != 1 && status != 2 && selected == true

    getSelectedWarnings: ->
      @where(status: 1, selected: true)

    getSelectedSilenced: ->
      @where(silenced: true, selected: true)

    getSelectedSilencedClients: ->
      @where(client_silenced: true, selected: true)

    getSelectedUnsilenced: ->
      @where(silenced: false, selected: true)

    getSelectedUnsilencedClients: ->
      @where(client_silenced: false, selected: true)

    toggleSelected: ->
      selected = true
      selected = false if @getSelected().length == @length
      @each (event) ->
        event.set(selected: selected)

    selectAll: ->
      @each (event) ->
        event.set(selected: true)

    selectNone: ->
      @each (event) ->
        event.set(selected: false)

    selectCritical: ->
      events = @getCriticals()
      events_selected = @getSelectedCriticals()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set(selected: selected)

    selectUnknown: ->
      events = @getUnknowns()
      events_selected = @getSelectedUnknowns()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set(selected: selected)

    selectWarning: ->
      events = @getWarnings()
      events_selected = @getSelectedWarnings()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set(selected: selected)

    selectSilenced: ->
      events = @getSilenced()
      events_selected = @getSelectedSilenced()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set(selected: selected)

    selectSilencedClients: ->
      events = @getSilencedClients()
      events_selected = @getSelectedSilencedClients()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set(selected: selected)

    selectUnsilenced: ->
      events = @getUnsilenced()
      events_selected = @getSelectedUnsilenced()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set(selected: selected)

    selectUnsilencedClients: ->
      events = @getUnsilencedClients()
      events_selected = @getSelectedUnsilencedClients()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set(selected: selected)

    resolveSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for event in @getSelected()
        event.resolve
          success: (model, response, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback

    silenceSelectedChecks: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for event in @getSelected()
        event.silence
          success: (model, response, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback

    unsilenceSelectedChecks: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for event in @getSelected()
        event.unsilence
          success: (model, response, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback

    silenceSelectedClients: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for event in @getSelected()
        SensuDashboard.Clients.get(event.get('client')).silence
          success: (model, response, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback

    unsilenceSelectedClients: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      for event in @getSelected()
        SensuDashboard.Clients.get(event.get('client')).unsilence
          success: (model, response, opts) =>
            @successCallback.call(this, model) if @successCallback
          error: (model, xhr, opts) =>
            @errorCallback.call(this, model) if @errorCallback
