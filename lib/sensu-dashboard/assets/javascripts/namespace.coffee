@namespace = (nspace, payload, context) ->
  payload = payload || {}
  context = context || window

  parts = nspace.split '.'
  parent = context
  currentPart = ''

  while currentPart = parts.shift()
    if parts.length != 0
      parent[currentPart] = parent[currentPart] || {}
    else
      parent[currentPart] = parent[currentPart] || payload

    parent = parent[currentPart]

  payload parent
