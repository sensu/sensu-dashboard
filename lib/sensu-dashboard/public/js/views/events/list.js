define([
  'jquery',
  'backbone',
  'underscore',
  'models/event',
  'models/client',
  'models/stash',
  'collections/events',
  'text!templates/events.tmpl',
  'views/events/list_table',
  'views/events/list_counts',
  'views/events/details_actions',
  'views/events/details_event',
  'views/events/details_client',
], function($,
            Backbone,
            _,
            EventModel,
            ClientModel,
            StashModel,
            EventsCollection,
            template,
            ListTableView,
            ListCountsView,
            DetailsActionsView,
            DetailsEventView,
            DetailsClientView) {
  var View = Backbone.View.extend({
    template: _.template(template),
    el: '#main',
    events: {
      'click #toggle-checkboxes': 'toggleSelected',
      'click #select-all': 'selectAll',
      'click #select-none': 'selectNone',
      'click #select-critical': 'selectCritical',
      'click #select-unknown': 'selectUnknown',
      'click #select-warning': 'selectWarning',
      'click #resolve-selected': 'resolveSelected',
      'click #silence-selected': 'silenceSelected',
      'click #unsilence-selected': 'unsilenceSelected',
      'click tr': 'showDetails',
    },
    initialize: function() {
      this.collection = new EventsCollection();
      this.collection.bind('reset', this.renderSubViews, this);
      this.collection.fetch({
        error: function(collection, response) {
          alert('Unable to fetch events from the Sensu API.\n'
            + 'Error ' + response['status'] + ': '
            + response['statusText']);
        }
      });
    },
    render: function() {
      $(this.el).html(this.template);
      this.renderSubViews();

      this.detailsActionsView = new DetailsActionsView({
        model: new Backbone.Model({
          event: new EventModel(),
          eventStash: new StashModel(),
          clientStash: new StashModel(),
        }),
      });

      this.detailsEventView = new DetailsEventView({
        model: new EventModel(),
      });

      this.detailsClientView = new DetailsClientView({
        model: new ClientModel(),
      });

      return this;
    },
    renderSubViews: function() {
      // TODO: this is currently being called twice on page load; although
      // there does not seem to be a performance hit, we should look into
      // a method to load it only once
      console.log('rendering subviews');
      var eventsView = new ListTableView({
        collection: this.collection
      });

      var countsView = new ListCountsView({
        collection: this.collection
      });

      eventsView.render();
      countsView.render();
    },
    toggleSelected: function() {
      this.collection.toggleSelected();
    },
    selectAll: function() {
      this.collection.selectAll();
    },
    selectNone: function() {
      this.collection.selectNone();
    },
    selectCritical: function () {
      this.collection.selectCritical();
    },
    selectUnknown: function() {
      this.collection.selectUnknown();
    },
    selectWarning: function() {
      this.collection.selectWarning();
    },
    resolveSelected: function() {
      this.collection.resolveSelected();
    },
    silenceSelected: function() {
      this.collection.silenceSelected();
    },
    unsilenceSelected: function() {
      this.collection.unsilenceSelected();
    },
    showDetails: function(e) {
      e.preventDefault();
      var id = $(e.currentTarget).data('id');
      var event = this.collection.getByCid(id);

      var eventStash = this.detailsActionsView.model.get('eventStash').set({
        id: 'silence/'+event.get('client')+'/'+event.get('check'),
      });

      var clientStash = this.detailsActionsView.model.get('clientStash').set({
        id: 'silence/'+event.get('client'),
      });

      this.detailsActionsView.model.set({
        event: event,
        eventStash: eventStash,
        clientStash: clientStash,
      });

      this.detailsEventView.model = event;

      this.detailsClientView.model.set({
        id: event.get('client'),
      });

      this.detailsActionsView.model.get('clientStash').fetch({
        error: function(stash, response) {
          if (response['status'] != 404) {
            alert('Unable to fetch client silence stash from the Sensu API.\n'
              + 'Error ' + response['status'] + ': '
              + response['statusText']);
          }
        }
      });

      this.detailsActionsView.model.get('eventStash').fetch({
        error: function(stash, response) {
          if (response['status'] != 404) {
            alert('Unable to fetch event silence stash from the Sensu API.\n'
             + 'Error ' + response['status'] + ': '
             + response['statusText']);
          }
        }
      });

      this.detailsClientView.model.fetch({
        error: function(user, response) {
          alert('Unable to fetch client from the Sensu API.\n'
            + 'Error ' + response['status'] + ': '
            + response['statusText']);
        }
      });

      this.detailsEventView.render();
      $('#event_modal').modal();      
    },
  });

  return new View;
});
