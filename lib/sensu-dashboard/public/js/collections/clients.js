define([
  'underscore',
  'backbone',
  'models/client',
], function(_, Backbone, Client) {
  return Backbone.Collection.extend({
    model: Client,
    url: '/clients',
    comparator: function(ev) {
      return ev.get('name')
    },
    toggleSelected: function() {
      selected = true
      if (this.where({selected: true}).length == this.length) {
        selected = false
      }
      this.each(function(clientItem) {
        clientItem.set({selected: selected})
      })
    },
    selectAll: function() {
      this.each(function(clientItem) {
        clientItem.set({selected: true})
      })
    },
    selectNone: function() {
      this.each(function(clientItem) {
        clientItem.set({selected: false})
      })
    },
    silenceSelected: function() {

    },
    unsilenceSelected: function() {

    }
  })
})
