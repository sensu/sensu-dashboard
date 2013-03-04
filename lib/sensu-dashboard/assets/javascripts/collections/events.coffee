namespace 'SensuDashboard.Collections', (exports) ->

  class exports.Events extends Backbone.Collection
    model: SensuDashboard.Models.Event,
    url: '/events'

    comparator: (event) ->
      event.get 'status_name'

    toggleSelected: ->
      selected = true
      selected = false if @where({selected: true}).length == @length
      @each (event) ->
        event.set {selected: true}

    selectAll: ->
      @each (event) ->
        event.set {selected: true}

    selectNone: ->
      @each (event) ->
        event.set {selected: false}

    selectCritical: ->
      selected = true
      selected = false if @where({status: 2, selected: true}).length == @where({status: 2}).length
      @each (event) ->
        event.set {selected: selected} if event.get 'status' == 2

    selectUnknown: ->
      selected = true
      @each (event) ->
        event.set {selected: true} if event.get('status') != 1 && event.get('status') != 2

    selectWarning: ->
      selected = true
      selected = false if @where({status: 1, selected: true}).length == @where({status: 1}).length
      @each (event) ->
        event.set {selected: true} if event.get('status') == 1

    resolveSelected: ->

    silenceSelected: ->

    unsilenceSelected: ->
