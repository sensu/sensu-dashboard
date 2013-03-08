Handlebars.registerHelper 'isClientSilenced', (client, stashes, block) ->
  for stash in stashes when stash.id is 'silence/'+client
    return block.fn(this)

  return block.inverse(this)

Handlebars.registerHelper 'isCheckSilenced', (client, check, stashes, block) ->
  for stash in stashes when stash.id is 'silence/'+client+'/'+check
    return block.fn(this)

  return block.inverse(this)
