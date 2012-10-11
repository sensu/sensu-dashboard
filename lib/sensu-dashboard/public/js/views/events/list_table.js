define([
  'jquery',
  'backbone',
  'underscore',
  'views/events/list_table_item',
], function($, Backbone, _, ListTableItemView) {
  return Backbone.View.extend({
    el: 'table#events > tbody',
    initialize: function() {
      this.collection.bind('add', this.render, this);
      this.collection.bind('reset', this.render, this);
    },
    render: function() {
      $(this.el).empty();
      _.each(this.collection.models, function(item) {
        $(this.el).append(new ListTableItemView({model: item}).render().el);
      }, this);

      return this;
    },
  });
});
