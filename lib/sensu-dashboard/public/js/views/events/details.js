define([
  'jquery',
  'backbone',
  'underscore',
  'models/event',
  'models/client',
  'text!templates/event_details.tmpl',
], function($, Backbone, _, EventModel, ClientModel, template) {
  return Backbone.View.extend({
    template: _.template(template),
    el: '#event_details',
    initialize: function() {
      this.model.on('change', this.render, this);
//      this.clientModel.on('change', this.render, this);
    },
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },
  });
});
