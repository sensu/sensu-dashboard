namespace 'SensuDashboard', (exports) ->

  class exports.MainState extends exports.State
    transition: (manager, view) ->
      $('#main').html(view.render().el)
      manager.pushTop(view)
