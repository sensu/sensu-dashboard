Handlebars.registerHelper 'selected', (selected) ->
  return if selected then 'checked' else ''
