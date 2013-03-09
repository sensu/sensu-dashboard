namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Events extends Backbone.Collection
    model: SensuDashboard.Models.Event,
    url: '/events'

    comparator: (event) ->
      event.get 'status_name'

    toggleSelected: ->
      selected = true
      selected = false if @where({ selected: true }).length == @length
      @each (event) ->
        event.set { selected: selected }

    selectAll: ->
      @each (event) ->
        event.set { selected: true }

    selectNone: ->
      @each (event) ->
        event.set { selected: false }

    selectCritical: ->
      events = @where({ status: 2 })
      events_selected = @where({ status: 2, selected: true })
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set { selected: selected }

    selectUnknown: ->
      events = @filter (event) ->
        status = event.get('status')
        return status != 1 && status != 2
      events_selected = @filter (event) ->
        status = event.get('status')
        selected = event.get('selected')
        return status != 1 && status != 2 && selected == true
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set { selected: selected }

    selectWarning: ->
      events = @where({ status: 1 })
      events_selected = @where({ status: 1, selected: true })
      for event in events
        selected = true
        selected = false if events_selected.length == events.length
        event.set { selected: selected }

    resolveSelected: ->
      console.log event for event in @where({ selected: true })

    silenceSelected: ->
      console.log event for event in @where({ selected: true })

    unsilenceSelected: ->
      console.log event for event in @where({ selected: true })
