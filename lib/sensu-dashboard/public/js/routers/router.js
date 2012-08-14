define([
  'jquery',
  'backbone',
  'underscore',
  'views/events/list',
], function($, Backbone, _, eventsListView) {
  var Router = Backbone.Router.extend({
    initialize: function() {
      this.mainView = eventsListView;
      Backbone.history.start();
    },
    routes: {
      '': 'events',
      '/events': 'events',
    },
    events: function() {
      this.mainView.render();
    }
  });

  return Router;
});
