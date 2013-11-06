Handlebars.registerHelper "selected", (selected) ->
  return if selected then "checked" else ""

Handlebars.registerHelper "truncate", (text, length) ->
  truncated = text.substring(0, length)
  if text.length > length
    truncated = truncated + "..."
  return truncated

Handlebars.registerHelper "strip", (text) ->
  return text.toString().replace(/^\s\s*/, '').replace(/\s\s*$/, '')

Handlebars.registerHelper "linkify", (text) ->
  exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig
  return text.toString().replace(exp,"<a href='$1'>$1</a>")

Handlebars.registerHelper "modalValue", (text) ->
  linkified = Handlebars.helpers.linkify(text)
  return Handlebars.helpers.strip(linkified)