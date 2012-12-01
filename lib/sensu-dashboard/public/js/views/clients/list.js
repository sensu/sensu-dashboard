define([
  'jquery',
  'backbone',
  'underscore',
  'models/client',
  'models/stash',
  'collections/clients',
  'text!templates/clients.tmpl',
  'views/clients/list_table',
], function($,
            Backbone,
            _,
            ClientModel,
            StashModel,
            ClientsCollection,
            template,
            ListTableView) {
  var View = Backbone.View.extend({
    template: _.template(template),
    el: '#main',
    events: {
      'click #toggle-checkboxes': 'toggleSelected',
      'click #select-all': 'selectAll',
      'click #select-none': 'selectNone',
      'click #silence-selected': 'silenceSelected',
      'click #unsilence-selected': 'unsilenceSelected',
      'click tr': 'showDetails',
    },
    initialize: function() {
      this.collection = new ClientsCollection()
      this.collection.bind('reset', this.renderSubViews, this)
      this.collection.fetch({
        error: function(collection, response) {
          alert('Unable to fetch clients from the Sensu API.\n'
            + 'Error ' + response['status'] + ': '
            + response['statusText'])
        }
      })
    },
    render: function() {
      $(this.el).html(this.template)
      this.renderSubViews()

      this.detailsActionsView = new DetailsActionsView({
        model: new Backbone.Model({
          client: new ClientModel(),
          clientStash: new StashModel(),
        }),
      })
/*
      this.detailsEventView = new DetailsEventView({
        model: new EventModel(),
      })

      this.detailsClientView = new DetailsClientView({
        model: new ClientModel(),
      })
*/
      return this
    },
    renderSubViews: function() {
      // TODO: this is currently being called twice on page load although
      // there does not seem to be a performance hit, we should look into
      // a method to load it only once
      console.log('rendering subviews')
      var clientsView = new ListTableView({
        collection: this.collection
      })
/*
      var countsView = new ListCountsView({
        collection: this.collection
      })
*/
      clientsView.render()
//      countsView.render()
    },
    toggleSelected: function() {
      this.collection.toggleSelected()
    },
    selectAll: function() {
      this.collection.selectAll()
    },
    selectNone: function() {
      this.collection.selectNone()
    },
    silenceSelected: function() {
      this.collection.silenceSelected()
    },
    unsilenceSelected: function() {
      this.collection.unsilenceSelected()
    },
    showDetails: function(e) {
      e.preventDefault()
      var id = $(e.currentTarget).data('id')
      var client = this.collection.getByCid(id)

      var clientStash = this.detailsActionsView.model.get('clientStash').set({
        id: 'silence/'+client.get('name'),
      })

      this.detailsActionsView.model.set({
        client: client,
        clientStash: clientStash,
      })

      this.detailsClientView.model = client

      this.detailsActionsView.model.get('clientStash').fetch({
        error: function(stash, response) {
          if (response['status'] != 404) {
            alert('Unable to fetch client silence stash from the Sensu API.\n'
              + 'Error ' + response['status'] + ': '
              + response['statusText'])
          }
        }
      })

//      this.detailsEventView.render()
      $('#client_modal').modal()
    },
  })

  return new View
})
