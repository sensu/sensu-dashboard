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
    events: {
      'click #toggle-checkboxes': 'toggleSelected',
      'click #select-all': 'selectAll',
      'click #select-none': 'selectNone',
      'click #select-critical': 'selectCritical',
      'click #select-unknown': 'selectUnknown',
      'click #select-warning': 'selectWarning',
      'click #resolve-selected': 'resolveSelected',
      'click #silence-selected': 'silenceSelected',
      'click #unsilence-selected': 'unsilenceSelected',
    },
    initialize: function() {
      this.collection = new EventsCollection();
      this.collection.bind('reset', this.renderSubViews, this);
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
      console.log('rendering subviews');
      var eventsView = new ListTableView({
        collection: this.collection
      });

      var countsView = new ListCountsView({
        collection: this.collection
      });

      eventsView.render();
      countsView.render();
    },
    toggleSelected: function() {
      this.collection.toggleSelected();
    },
    selectAll: function() {
      this.collection.selectAll();
    },
    selectNone: function() {
      this.collection.selectNone();
    },
    selectCritical: function () {
      this.collection.selectCritical();
    },
    selectUnknown: function() {
      this.collection.selectUnknown();
    },
    selectWarning: function() {
      this.collection.selectWarning();
    },
    resolveSelected: function() {
      this.collection.resolveSelected();
    },
    silenceSelected: function() {
      this.collection.silenceSelected();
    },
    unsilenceSelected: function() {
      this.collection.unsilenceSelected();
    }
  });

  return new View;
});
