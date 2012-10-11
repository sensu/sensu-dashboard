define([
  'underscore',
  'backbone',
  'models/stash',
], function(_, Backbone, Stash) {
  return Backbone.Collection.extend({
    model: Stash,
    url: '/stashes',
  });
});
