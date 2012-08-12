(function($) {

  // Force application/json accept header for all jQuery AJAX requests
  $.ajaxSetup({
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json'
    }
  });

  // EventModel
  window.EventModel = Backbone.Model.extend({
    defaults: {
      client: 'nil',
      check: 'nil',
      occurrences: 0,
      output: 'nil',
      status: 3,
      flapping: false,
      issued: '0000-00-00T00:00:00Z',
      selected: false
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

  // EventCountModel
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

  // EventsCollection
  window.EventsCollection = Backbone.Collection.extend({
    model: EventModel,
    url: '/events',
    comparator: function(ev) {
      return ev.get('status_name');
    }
  });

  // EventCountView
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

  // EventsListView
  window.EventsListView = Backbone.View.extend({
    el: $('#events > tbody'),
    initialize: function() {
      this.collection.bind('reset', this.render, this);
    },
    render: function() {
      $(this.el).empty();
      _.each(this.collection.models, function(eventItem) {
        $(this.el).append(new EventListItemView({model: eventItem}).render().el);
      }, this);
      return this;
    }
  });

  // EventListItemView
  window.EventListItemView = Backbone.View.extend({
    tagName: 'tr',
    template: _.template($('#tpl-event-list-item').html()),
    render: function(eventItem) {
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.attr('class', this.model.get('status_name'));
      this.$el.children('.select_col')
        .children('input[type=checkbox]')
        .attr('checked', this.model.get('selected') ? 'selected' : false);
      return this;
    },
    events: {
      'click input[type=checkbox]':'toggleSelected'
    },
    toggleSelected: function() {
      this.model.toggleSelected();
    }
  });

  // EventsTableColumnListView

  // Events

  // EventsPageView
  window.EventsPageView = Backbone.View.extend({
    el: $('body'),
    events: {
      'click #toggle-checkboxes': 'toggleSelected',
      'click #select-all': 'selectAll',
      'click #select-none': 'selectNone',
      'click #select-critical': 'selectCritical',
      'click #select-unknown': 'selectUnknown',
      'click #select-warning': 'selectWarning'
    },
    initialize: function() {
      this.selected = false;
    },
    toggleSelected: function() {
      this.selected = !this.selected;
      eventsList.each(function(eventItem) {
        eventItem.set({selected: eventsPageView['selected']});
      });
      eventsListView.render();
    },
    selectAll: function() {
      this.selected = true;
      eventsList.each(function(eventItem) {
        eventItem.set({selected: true});
      });
      eventsListView.render();
    },
    selectNone: function() {
      this.selected = false;
      eventsList.each(function(eventItem) {
        eventItem.set({selected: false});
      });
      eventsListView.render();
    },
    selectCritical: function() {
      eventsList.each(function(eventItem) {
        if (eventItem.get('status') == 2)
          eventItem.set({selected: true});
      });
      eventsListView.render();
    },
    selectUnknown: function() {
      eventsList.each(function(eventItem) {
        if (eventItem.get('status') != 1 && eventItem.get('status') != 2)
          eventItem.set({selected: true});
      });
      eventsListView.render();
    },
    selectWarning: function() {
      eventsList.each(function(eventItem) {
        if (eventItem.get('status') == 1)
          eventItem.set({selected: true});
      });
      eventsListView.render();
    }
  });
  eventsPageView = new EventsPageView();

  this.eventsList = new EventsCollection();
  this.eventsListView = new EventsListView({collection: this.eventsList});
  this.eventsList.fetch({
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

})(jQuery);
