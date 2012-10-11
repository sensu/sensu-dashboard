define([
  'jquery',
  'backbone',
  'underscore',
], function($, Backbone, _) {
  return Backbone.Model.extend({
    defaults: {
      warning: 0,
      critical: 0,
      unknown: 0,
      total: 0
    },
    initialize: function() {
      this.setTotal();
    },
    setTotal: function() {
      this.set({
        total: this.get('warning') + this.get('critical') + this.get('unknown')
      });
    }
  });
});
