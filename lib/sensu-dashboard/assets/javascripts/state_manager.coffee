namespace 'SensuDashboard', (exports) ->

  class exports.StateManager extends Backbone.Router

    views: []

    constructor: (states, defaultState) ->
      @_buildStates(states)
      @_buildRoutes()
      @_defaultRoute(defaultState)
      super

    register: (view) ->
      @views.push(view)

    disposeAll: ->
      view.dispose() for view in @views

    reset: ->
      @disposeAll()
      @views = []

    count: ->
      @views.length

    pushTop: (view) ->
      @reset()
      @register(view)

    # Private

    _getState: (name) ->
      _.find @states, (state) ->
        state.name == name

    _buildStates: (states) ->
      @states = []
      @states.push(new state(name: name)) for name, state of states

    _buildRoutes: ->
      for state in @states
        @route state.route, state.name, @_enterView(state)

    _defaultRoute: (defaultState) ->
      defaultState ||= @states[0].name
      state = @_getState(defaultState)
      @route "", defaultState, @_enterView(state)

    _enterView: (state) ->
      (context) ->
        view = state.enter(context)
        state.transition(@, view)
