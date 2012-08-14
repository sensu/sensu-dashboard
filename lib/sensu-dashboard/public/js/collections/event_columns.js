define([
  'backbone',
  'models/event_column'
], function(Backbone, event_column) {
  var collection = Backbone.Collection.extend({
    localStorage: new Backbone.LocalStorage('EventColumnsCollection'),
    model: event_column
  });

  return collection;
});
