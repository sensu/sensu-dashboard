define([
  'underscore',
  'backbone',
  'models/event',
], function(_, Backbone, Event) {
  return Backbone.Collection.extend({
    model: Event,
    url: '/events',
    comparator: function(ev) {
      return ev.get('status_name');
    },
    toggleSelected: function() {
      selected = true;
      if (this.where({selected: true}).length == this.length) {
        selected = false;
      }
      this.each(function(eventItem) {
        eventItem.set({selected: selected});
      });
    },
    selectAll: function() {
      this.each(function(eventItem) {
        eventItem.set({selected: true});
      });
    },
    selectNone: function() {
      this.each(function(eventItem) {
        eventItem.set({selected: false});
      });
    },
    selectCritical: function() {
      selected = true;
      if (this.where({status: 2, selected: true}).length == this.where({status: 2}).length) {
        selected = false;
      }
      this.each(function(eventItem) {
        if (eventItem.get('status') == 2) {
          eventItem.set({selected: selected});
        }
      });
    },
    selectUnknown: function() {
      this.each(function(eventItem) {
        if (eventItem.get('status') != 1 && eventItem.get('status') != 2) {
          eventItem.set({selected: true});
        }
      });
    },
    selectWarning: function() {
      this.each(function(eventItem) {
        if (eventItem.get('status') == 1) {
          eventItem.set({selected: true});
        }
      });
    }
  });
});
