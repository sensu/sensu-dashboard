define([
  'jquery',
  'backbone',
  'underscore',
  'models/event',
  'models/client',
  'text!templates/event_details.tmpl',
  'text!templates/client_details.tmpl',
], function($, Backbone, _, EventModel, ClientModel, eventTemplate, clientTemplate) {
  return Backbone.View.extend({
    eventTemplate: _.template(eventTemplate),
    clientTemplate: _.template(clientTemplate),
    el: '#details',
    initialize: function() {
      this.options.eventModel.on('change', this.render, this);
      this.options.clientModel.on('change', this.render, this);
    },
    render: function() {
      this.$el.empty();
      this.$el.append(this.eventTemplate(this.options.eventModel.toJSON()));
      this.$el.append(this.clientTemplate(this.options.clientModel.toJSON()));
      return this;
    },
  });
});
