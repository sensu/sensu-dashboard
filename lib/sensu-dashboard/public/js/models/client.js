define([
  'backbone',
  'underscore',
], function(Backbone, _) {
  return Backbone.Model.extend({
    defaults: {
      name: 'nil',
      address: 'nil',
      subscriptions: [],
      timestamp: 0,
    },
    urlRoot: '/clients',
  });
});
