/*AppView = Backbone.View.extend({
  el: '#content',
  initialize: function() {
  },
  render: function() {
    $(this.el).html('<h3>meow</h3>');
  }
});

// Render the app
var appView = new AppView;
appView.render();

var AppRouter = Backbone.Router.extend({
  routes: {
    'events': 'events',
    'stashes': 'stashes',
    'clients': 'clients'
  },
  events: function() {
    // Default Event Columns
    var eventColumns = new TableColumns;
    eventColumns.add(new TableColumn({ id: 1, name: 'client', display_name: 'Client' }));
    eventColumns.add(new TableColumn({ id: 2, name: 'check', display_name: 'Check' }));
    eventColumns.add(new TableColumn({ id: 3, name: 'output', display_name: 'Output' }));
    eventColumns.add(new TableColumn({ id: 4, name: 'test', display_name: 'Testing' }));

    // EventColumns View
    var eventColumnsView = new EventColumnsView({ collection: eventColumns });
  },
  stashes: function() {
    alert('stashes');
  },
  clients: function() {
    alert('clients');
  }
});

var App = new AppRouter();
Backbone.history.start();

TableColumn = Backbone.Model.extend({
  defaults: {
    id: 1,
    name: 'nil',
    display_name: 'nil'
  }
});
/*
Event = Backbone.Model.extend({
  defaults: {
    client: 'nil',
    check: 'nil',
    occurrences: 0,
    output: 'nil',
    status: 3,
    flapping: false,
    issued: '0000-00-00T00:00:00Z'
  }
});

EventColumnsCollection = Backbone.Collection.extend({
  model: EventColumn
});

EventsCollection = Backbone.Collection.extend({
  model: Event,
  url: '/events'
});

EventsView = Backbone.View.extend({
  tagName: 'tbody',

  initialize: function() {
    _.bindAll(this, 'render');
  },

  render: function() {
    $(this.el).html(new EventColumnView);
    _.each(this.model.models, function(ev) {
      $(this.el).append(new EventView({model: ev}).render().el);
    }, this);
    return this;
  }
});

var TableColumnView = Backbone.View.extend({
  el: 'table#events',
  template: _.template($('#tpl-event-column').html()),
  initialize: function() {
    _.bindAll(this, 'render');
  },
  render: function() {
    _.each(this.model.models, function(evc) {
      $(this.el).append('<th>meow</th>');
    }, this);
    return this;
  }
});
*/
/*var EventView = Backbone.View.extend({
  tagName: 'tr',
  template: _.template($('#tpl-event-row').html()),
  render: function(ev) {
    $(this.el).html(this.template(this.model.toJSON()));
    return this;
  }
});*/

//var eventColumnView = new EventColumnView({model:eventColumns});

/*var events = new EventsCollection;
events.fetch({
  error: function(model, response) {
    console.log(response);
  },
  success: function(collection, response) {
    //console.log(events.models);
    //$('table#events').html(new EventsView({model:events}).render().el);
  }
});*/
