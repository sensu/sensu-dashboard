/**
 * Routing
 */
var AppRouter = Backbone.Router.extend({
  routes: {
    'events': 'events',
    'stashes': 'stashes',
    'clients': 'clients'
  },
  events: function() {
    alert('events');
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

var EventColumn = Backbone.Model.extend({
  defaults: {
    id: 1,
    name: 'nil',
    display_name: 'nil'
  }
});

var Event = Backbone.Model.extend({
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

var EventColumnsCollection = Backbone.Collection.extend({
  model: EventColumn
});

var EventsCollection = Backbone.Collection.extend({
  model: Event,
  url: '/events'
});

var EventsView = Backbone.View.extend({
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

var EventColumnView = Backbone.View.extend({
  tagName: 'td',
  template: _.template($('#tpl-test-row').html()),
  render: function(ev) {
    $(This.el).html(this.template(this.model.toJSON()));
    return this;
  }
});

var EventView = Backbone.View.extend({
  tagName: 'tr',
  template: _.template($('#tpl-test-row').html()),
  render: function(ev) {
    $(this.el).html(this.template(this.model.toJSON()));
    return this;
  }
});

var eventColumns = new EventColumnsCollection;
eventColumns.add({id: 1, name: client, display_name: 'Client'});
eventColumns.add({id: 2, name: check, display_name: 'Check'});
eventColumns.add({id: 3, name: output, display_name: 'Output'});

var eventColumnView = new EventColumnView;

var events = new EventsCollection;
console.log('here');
events.fetch({
  error: function(model, response) {
    console.log(response);
  },
  success: function(collection, response) {
    console.log(events.models);
    $('table#events').html(new EventsView({model:events}).render().el);
  }
});
