(function($) {

  // Force application/json accept header for all jQuery AJAX requests
  $.ajaxSetup({
    headers: {
      Accept: 'application/json'
    }
  });

  // Event Model
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

  // Event Count Model
  window.EventCountModel = Backbone.Model.extend({
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
      this.set({total: this.get('warning') + this.get('critical') + this.get('unknown')});
    }
  });

  // Table Column Model
  window.TableColumnModel = Backbone.Model.extend({
    defaults: {
      id: 1,
      name: 'nil',
      display_name: 'nil'
    }
  });

  // Events Collection
  window.EventsCollection = Backbone.Collection.extend({
    model: EventModel,
    url: '/events',
    comparator: function(ev) {
      return ev.get('status_name');
    }
  });

  // Event Count View
  window.EventCountView = Backbone.View.extend({
    el: $('#event_counts'),
    initialize: function() {
      this.template = _.template($('#tpl-event-count').html());
      this.render();
    },
    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    }
  });

  // Events View
  window.EventsView = Backbone.View.extend({
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
    render: function(model) {
      return this;
    }
  });

  // Fetch events
  events = new EventsCollection();
  warning = events.where({status: 1}),
  events.fetch({
    success: function(collection, response) {
      // Create an instance of the EventCount model
      event_count = new EventCountModel({
        warning: collection.where({status: 1}).length,
        critical: collection.where({status: 2}).length,
        unknown: collection.where({status: 3}).length
      });

      // Create & render the event count view
      eventCountView = new EventCountView({model: event_count});

      // Create & render the events view
      eventView = new EventsView({collection: events});
    },
    error: function(collection, response) {
      console.log('Error fetching events from the Sensu API');
      console.log(collection);
      console.log(response);
    }
  })

})(jQuery);
