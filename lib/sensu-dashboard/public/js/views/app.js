define([
  'jquery',
  'backbone',
  'underscore',
  'collections/event_columns',
  'text!templates/main.tmpl'
], function($, Backbone, _, EventColumns, template) {
  var View = Backbone.View.extend({
    el: '#main',
    initialize: function() {
      this.collections = new EventColumnModel();
      this.template = _.template();
    },
    render: function() {
      $(this.el).append(this.template);
    }
  });

  return new View();
});
        
