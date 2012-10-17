define([
  'jquery',
  'backbone',
  'underscore',
  'models/event',
  'models/client',
  'collections/events',
  'text!templates/events.tmpl',
  'views/events/list_table',
  'views/events/list_counts',
  'views/events/details',
], function($,
            Backbone,
            _,
            EventModel,
            ClientModel,
            EventsCollection,
            template,
            ListTableView,
            ListCountsView,
            DetailsView) {
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
        success: function(collection, response) {
        },
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
      this.detailView = new DetailsView({eventModel: new EventModel(), clientModel: new ClientModel()});
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
      this.detailView.options.eventModel = this.collection.getByCid(id);
      this.detailView.options.clientModel.set({id: this.detailView.options.eventModel.get('client')});

      this.detailView.options.clientModel.fetch({
        success: function(user) {
          console.log(user.toJSON());
        } 
      });
      this.detailView.render();
      $('#event_modal').modal();      
    },
  });

  return new View;
});
