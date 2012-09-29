define([
  'jquery',
  'backbone',
  'underscore',
  'models/event',
  'text!templates/event_details.tmpl',
], function($, Backbone, _, model, template) {
  return Backbone.View.extend({
    template: _.template(template),
    el: '#event_details',
    initialize: function() {
      this.model.on('change', this.render, this);
    },
    render: function() {
//      console.log(this.model.toJSON());
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },
  });
});
