namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Events extends Backbone.Collection
    model: SensuDashboard.Models.Event,
    url: '/events'

    comparator: (event) ->
      event.get 'status_name'

    getSelected: ->
      @where({ selected: true })

    getCriticals: ->
      @where({ status: 2 })

    getUnknowns: ->
      @filter (event) ->
        status = event.get('status')
        return status != 1 && status != 2

    getWarnings: ->
      @where({ status: 1 })

    getSelectedCriticals: ->
      @where({ status: 2, selected: true })

    getSelectedUnknowns: ->
      @filter (event) ->
        status = event.get('status')
        selected = event.get('selected')
        return status != 1 && status != 2 && selected == true

    getSelectedWarnings: ->
      @where({ status: 1, selected: true })

    toggleSelected: ->
      selected = true
      selected = false if @getSelected().length == @length
      @each (event) ->
        event.set { selected: selected }

    selectAll: ->
      @each (event) ->
        event.set { selected: true }

    selectNone: ->
      @each (event) ->
        event.set { selected: false }

    selectCritical: ->
      events = @getCriticals()
      events_selected = @getSelectedCriticals()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set { selected: selected }

    selectUnknown: ->
      events = @getUnknowns()
      events_selected = @getSelectedUnknowns()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set { selected: selected }

    selectWarning: ->
      events = @getWarnings()
      events_selected = @getSelectedWarnings()
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set { selected: selected }

    resolveSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      success = true
      for event in @getSelected()
        event.resolve
          error: (model, xhr, opts) =>
            success = false
            @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback
      @successCallback.call(this) if @successCallback && success

    silenceSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      success = true
      for event in @getSelected()
        event.silence
          error: (model, xhr, opts) =>
            success = false
            @errorCallback.apply(this, [model, xhr, opts]) if @errorCallback
      @successCallback.call(this) if @successCallback && success

    unsilenceSelected: (options = {}) ->
      @successCallback = options.success
      @errorCallback = options.error
      success = true
      for event in @getSelected()
        event.unsilence
          error: (model, xhr, opts) =>
            success = false
            @errorCallback.apply(this, [model, response, opts]) if @errorCallback
      @successCallback.call(this) if @successCallback && success
