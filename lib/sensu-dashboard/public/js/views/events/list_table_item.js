define([
  'jquery',
  'backbone',
  'underscore',
  'models/event',
  'text!templates/events_list_item.tmpl',
], function($, Backbone, _, model, template) {
  return Backbone.View.extend({
    template: _.template(template),
    tagName: 'tr',
    initialize: function() {
      this.model.on('change', this.render, this);
      this.model.on('destroy', this.remove, this);
    },
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.attr('class', this.model.get('status_name'));
      this.$el.children('.select_col')
        .children('input[type=checkbox]')
        .attr('checked', this.model.get('selected') ? 'selected' : false);

      return this;
    },
    events: {
      'click input[type=checkbox]':'toggleSelected'
    },
    toggleSelected: function() {
      this.model.toggleSelected();
    }
  });
});
