namespace 'SensuDashboard', (exports) ->

  class exports.State

    collection: null

    model: null

    route: ""

    _beforeSetupView: null
    setupView: null
    _afterSetupView: null

    constructor: (opts) ->
      @name = opts.name

    enter: ->

      context = {}
      context.model = @model() if @model
      context.collection = @collection() if @collection

      view = @view(context)

      @_beforeSetupView(view, attributes) if @_beforeSetupView && _.isFunction(@_beforeSetupView)
      @setupView(view, attributes) if @setupView && _.isFunction(@setupView)
      @_afterSetupView(view, attributes) if @_afterSetupView && _.isFunction(@_afterSetupView)

      view

    exit: ->
      # ..
