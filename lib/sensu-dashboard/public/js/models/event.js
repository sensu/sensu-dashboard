define([
  'backbone',
  'underscore',
], function(Backbone, _) {
  return Backbone.Model.extend({
    defaults: {
      client: 'nil',
      check: 'nil',
      occurrences: 0,
      output: 'nil',
      status: 3,
      flapping: false,
      issued: '0000-00-00T00:00:00Z',
      selected: false,
    },
    initialize: function() {
      this.setOutputIfEmpty(this.get('output'));
      this.setStatusName(this.get('status'));
    },
    setOutputIfEmpty: function(output) {
      if(output == '') this.set({output: 'nil output'});
    },
    setStatusName: function(id) {
      switch(id) {
        case 1:
          this.set({status_name: 'warning'});
          break;
        case 2:
          this.set({status_name: 'critical'});
          break;
        default:
          this.set({status_name: 'unknown'});
          break;
      }
    },
    toggleSelected: function() {
      this.set({selected: !this.get('selected')});
    }
  });
});
