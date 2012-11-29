define([
  'jquery',
  'backbone',
  'underscore',
  'text!templates/actions_details.tmpl',
], function($, Backbone, _, template) {
  return Backbone.View.extend({
    template: _.template(template),
    el: '#actions',
    events: {
      'click #silence-client': 'silenceClient',
      'click #silence-check': 'silenceCheck',
      'click #resolve-event': 'resolveEvent',
    },
    initialize: function() {
      this.model.on('change', this.render, this);
    },
    render: function() {
      console.log(this.model);
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },
    silenceClient: function() {
      console.log('clicked silence client');
      if (this.model.get('clientStash').get('timestamp')) {
        this.model.get('clientStash').destroy({
          success: function() {
            console.log('destroyed the stash');
          }
        });
      } else {
        this.model.get('clientStash').save({
          success: function() {
            console.log('created the stash');
          }
        });
      }
    },
    silenceCheck: function() {
      console.log('clicked silence event');
    },
    resolveEvent: function() {
      console.log('clicked resolve event');
    },
  });
});
