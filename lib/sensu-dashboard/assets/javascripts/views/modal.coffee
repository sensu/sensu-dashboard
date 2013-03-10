namespace 'SensuDashboard.Views', (exports) ->

  class exports.Modal extends SensuDashboard.Views.Base

    tagName: 'div'

    className: 'modal hide fade'

    attributes:
      tabindex: '-1'
      role: 'dialog'
