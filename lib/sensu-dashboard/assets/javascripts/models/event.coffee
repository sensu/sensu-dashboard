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

    initialize: ->
      @setOutputIfEmpty @get('output')
      @setStatusName @get('status')

    setOutputIfEmpty: (output) ->
      if output == ''
        @set {output: 'nil output'}

    setStatusName: (status) ->
      switch status
        when 1 then @set {status_name: 'warning'}
        when 2 then @set {status_name: 'critical'}
        else @set {status_name: 'unknown'}
