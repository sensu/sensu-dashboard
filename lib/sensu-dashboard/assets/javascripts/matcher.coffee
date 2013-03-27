namespace "SensuDashboard", (exports) ->

  class exports.Matcher

    constructor: (options = {}) ->
      options = _.defaults(options, {
        threshold: 0.70
        sources: []
      })
      @sources = options.sources
      @threshold = options.threshold

    query: (query) ->
      results = []

      for source in @sources
        source.each (model) =>

          score = if model.validForQuery
            model.validForQuery(query, @threshold)
          else
            score = liquidMetal.score(model.get("name"), query)
            score if score > @threshold

          results.push({
            score: score
            model: model
          }) if score > 0

      results.sort((a,b) -> b.score - a.score)
      _.pluck(results, "model")

    addSource: (source) ->
      @sources.push(source)
