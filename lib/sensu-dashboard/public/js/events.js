(function($) {

  $.ajaxSetup({
    headers: {
      Accept: 'application/json'
    }
  });

  window.EventModel = Backbone.Model.extend({
    defaults: {
      client: 'nil',
      check: 'nil',
      occurrences: 0,
      output: 'nil',
      status: 3,
      flapping: false,
      issued: '0000-00-00T00:00:00Z'
    },
    initialize: function() {
      this.setStatusName(this.get('status'));
    },
    setStatusName: function(id) {
      switch(id) {
        case 1:
          this.set({status_name: 'warning'});
          break;
        case 2:
          this.set({status_name: 'critical'});
          break;
        case 3:
          this.set({status_name: 'unknown'});
          break;
      }
    }
  });

  window.TableColumnModel = Backbone.Model.extend({
    defaults: {
      id: 1,
      name: 'nil',
      display_name: 'nil'
    }
  });

  window.EventsCollection = Backbone.Collection.extend({
    model: EventModel,
    url: '/events',
    comparator: function(ev) {
      return ev.get('status_name');
    }
  });

  window.EventCollectionView = Backbone.View.extend({
    el: $('#events > tbody'),
    initialize: function() {
      this.template = _.template($('#tpl-event-row').html());
      _(this).bindAll('add');
      this._eventViews = [];
      this.collection.each(this.add);
      this.collection.bind('add', this.add);
    },
    add: function(model) {
      $(this.el).append(this.template(model.toJSON()));
    },
    render: function(data) {
      return this;
    }
  });

  events = new EventsCollection();
  events.fetch({
    success: function(collection, response) {
      eventView = new EventCollectionView({collection: events});
    },
    error: function(collection, response) {
      console.log('Error fetching events');
      console.log(collection);
      console.log(response);
    }
  })

})(jQuery);
