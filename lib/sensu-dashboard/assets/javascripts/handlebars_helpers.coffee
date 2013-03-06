Handlebars.registerHelper 'isClientSilenced', (client, stashes, block) ->
  for stash in stashes when stash.id is 'silence'
    return block.fn(this) if stash['silence/'+client]

  return block.inverse(this)

Handlebars.registerHelper 'isCheckSilenced', (client, check, stashes, block) ->
  for stash in stashes when stash.id is 'silence'
    return block.fn(this) if stash['silence/'+client+'/'+check]

  return block.inverse(this)
