(function($) {

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
    },
    error: function(collection, response) {
      console.log('Error fetching events from the Sensu API');
      console.log(collection);
      console.log(response);
    }
  });

})(jQuery);
