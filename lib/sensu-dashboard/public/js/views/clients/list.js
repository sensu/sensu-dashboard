define([
  'jquery',
  'backbone',
  'underscore',
  'text!templates/clients.tmpl',
], function($, Backbone, _, template) {
  var View = Backbone.View.extend({
    el: '#main',
    initialize: function() {
      this.template = _.template(template);
    },
    render: function() {
      $(this.el).html(this.template);
      return this;
    }
  });

  return new View;
});
