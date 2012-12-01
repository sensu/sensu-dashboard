define([
  'jquery',
  'backbone',
  'underscore',
  'models/client',
  'text!templates/clients_list_item.tmpl',
], function($, Backbone, _, model, template) {
  return Backbone.View.extend({
    template: _.template(template),
    tagName: 'tr',
    events: {
      'click input[type=checkbox]': 'toggleSelected',
    },
    initialize: function() {
      this.model.on('change', this.render, this);
      this.model.on('destroy', this.remove, this);
    },
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.attr('data-id', this.model.cid);
      this.$el.children('.select_col')
        .children('input[type=checkbox]')
        .attr('checked', this.model.get('selected') ? 'selected' : false);

      return this;
    },
    toggleSelected: function() {
      this.model.toggleSelected();
    },
  });
});
