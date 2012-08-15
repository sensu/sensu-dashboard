define([
  'jquery',
  'backbone',
  'underscore',
  'collections/events',
  'text!templates/events.tmpl',
  'views/events/list_table',
  'views/events/list_counts',
], function($, Backbone, _, EventsCollection, template, ListTableView, ListCountsView) {
  var View = Backbone.View.extend({
    template: _.template(template),
    el: '#main',
    initialize: function() {
      this.collection = new EventsCollection();
      this.collection.bind('all', this.renderSubViews, this);
      this.collection.fetch(); // TODO: display notifications when receiving errors from API
    },
    render: function() {
      $(this.el).html(this.template);
      this.renderSubViews();
      return this;
    },
    renderSubViews: function() {
      // TODO: this is currently being called twice on page load; although
      // there does not seem to be a performance hit, we should look into
      // a method to load it only once
      var eventsView = new ListTableView({
        collection: this.collection
      });

      var countsView = new ListCountsView({
        collection: this.collection
      });

      eventsView.render();
      countsView.render();
    }
  });

  return new View;
});
