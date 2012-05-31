(function($) {

  // Force application/json accept header for all jQuery AJAX requests
  $.ajaxSetup({
    headers: {
      Accept: 'application/json',
      "Content-Type": 'application/json'
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
      issued: '0000-00-00T00:00:00Z',
      selected: true
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
        case 3:
          this.set({status_name: 'unknown'});
          break;
      }
    },
    toggleSelected: function() {
      this.set({selected: !this.get('selected')});
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

  // Event View
  window.EventView = Backbone.View.extend({
    tagName: 'tr',
    template: _.template($('#tpl-event-row').html()),
    events: {

    },
    initialize: function() {
      this.model.bind('change', this.change, this);
      this.model.bind('remove', this.remove, this);
      this.model.bind('all', this.render, this);
    },
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.attr('class', this.model.get('status_name'));
      return this;
    },
    change: function() {
      console.log('model has changed');
    }
  });

  // Create an empty list of events
  events = new EventsCollection();

  // Events View
  window.EventsView = Backbone.View.extend({
    el: $('#events > tbody'),
    initialize: function() {
      this.collection.bind('all', this.render, this);
    },
    render: function() {
      var eventViews = '';
      this.collection.each(function(model) {
       eventViews += new EventView({model: model}).render().el.outerHTML;
      });
      this.$el.html(eventViews);
    }
  });
  new EventsView({collection: events});

  this.events.fetch({
    success: function(collection, response) {
      // Create an instance of the EventCount model
      event_count = new EventCountModel({
        warning: collection.where({status: 1}).length,
        critical: collection.where({status: 2}).length,
        unknown: collection.where({status: 3}).length
      });

      // Create & render the event count view
      eventCountView = new EventCountView({model: event_count});
    },
    error: function(collection, response) {
      console.log('Error fetching events from the Sensu API');
      console.log(collection);
      console.log(response);
    }
  });

  // Events Page View
  window.EventsPageView = Backbone.View.extend({
    el: $('body'),
    events: {
      'click #toggle-checkboxes': 'toggleSelected'
    },
    initialize: function() {
      this.selected = true;
    },
    toggleSelected: function() {
      this.selected = !this.selected;
      events.each(function(ev) {
        console.log(ev);
      });
    }
  });
  eventsPageView = new EventsPageView();

})(jQuery);
