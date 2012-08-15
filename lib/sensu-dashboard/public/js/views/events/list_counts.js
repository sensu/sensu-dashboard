define([
  'jquery',
  'backbone',
  'underscore',
  'models/event_counts',
  'text!templates/event_counts.tmpl',
], function($, Backbone, _, EventCounts, template) {
  return Backbone.View.extend({
    el: 'ul#event_counts',
    initialize: function() {
      this.collection.bind('add', this.render, this);
      this.collection.bind('reset', this.render, this);
      this.template = _.template(template);
    },
    render: function() {
      this.model = new EventCounts({
        warning: this.collection.where({status: 1}).length,
        critical: this.collection.where({status: 2}).length,
        unknown: this.collection.where({status: 3}).length // TODO: check for all status codes that are not 1 or 2
      });
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    }
  });
});
