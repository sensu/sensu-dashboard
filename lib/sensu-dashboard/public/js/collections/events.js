define([
  'underscore',
  'backbone',
  'models/event',
], function(_, Backbone, Event) {
  return Backbone.Collection.extend({
    model: Event,
    url: '/events',
    comparator: function(ev) {
      return ev.get('status_name');
    }
  });
});
