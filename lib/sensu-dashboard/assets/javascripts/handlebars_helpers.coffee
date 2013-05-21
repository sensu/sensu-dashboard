Handlebars.registerHelper "selected", (selected) ->
  return if selected then "checked" else ""

Handlebars.registerHelper "truncate", (text, length) ->
  truncated = text.substring(0, length)
  if text.length > length
    truncated = truncated + "..."
  return truncated
