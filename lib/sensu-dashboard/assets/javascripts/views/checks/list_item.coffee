namespace 'SensuDashboard.Views.Checks', (exports) ->

  class exports.ListItem extends SensuDashboard.Views.ListItem

    name: 'checks/list_item'

    className: ->
      @model.get('name')

    render: ->
      @$el.html(@template(@presenter()))
      this

    presenter: ->
      _.extend(@model.toJSON(), {
        standalone: @model.get('standalone') || 'false'
      })
