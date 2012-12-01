define([
  'jquery',
  'backbone',
  'underscore',
  'views/events/list',
  'views/clients/list',
  'views/stashes/list',
], function($, Backbone, _, eventsListView, clientsListView, stashesListView) {
  var Router = Backbone.Router.extend({
    initialize: function() {
      this.eventsListView = eventsListView;
      this.clientsListView = clientsListView;
      this.stashesListView = stashesListView;
      Backbone.history.start();
    },
    routes: {
      '': 'events',
      'events': 'events',
      'clients': 'clients',
      'stashes': 'stashes',
    },
    events: function() {
      $('ul#navigation').children().removeClass('active');
      $('ul#navigation').children('#nav_'+this.routes[Backbone.history.fragment]).addClass('active');
      this.eventsListView.render();
    },
    clients: function() {
      $('ul#navigation').children().removeClass('active')
      $('ul#navigation').children('#nav_'+this.routes[Backbone.history.fragment]).addClass('active')
      this.clientsListView.render()
    },
    stashes: function() {
      $('ul#navigation').children().removeClass('active')
      $('ul#navigation').children('#nav_'+this.routes[Backbone.history.fragment]).addClass('active')
      this.stashesListView.render()
    },
  })

  return Router
})
