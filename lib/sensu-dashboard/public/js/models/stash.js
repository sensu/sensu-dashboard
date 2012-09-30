define([
  'backbone',
  'underscore',
], function(Backbone, _) {
  return Backbone.Model.extend({
    urlRoot: '/stashes',
  });
});
