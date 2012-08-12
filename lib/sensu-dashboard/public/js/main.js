(function($) {

  window.EventColumnModel = Backbone.Model.extend({
    defaults: {
      id: 1,
      name: 'nil'
    }
  });

  window.EventColumnsCollection = Backbone.Collection.extend({
    localStorage: new Backbone.LocalStorage('EventColumnsCollection'),
    model: EventColumnModel,
    add: function(model) {
      var duplicates = this.filter(function(_model) {
        return _model.get('name') === model.get('name');
      });

      if (! _(duplicates).isEmpty)
        this.remove(duplicates);

      Backbone.Collection.prototype.add.call(this, model);
    }
  });

  window.EventColumnsListView = Backbone.View.extend({
    el: $('select#eventColumnsList'),
    initialize: function() {
      this.collection.bind('all', this.render, this);
    },
    render: function() {
      _.each(this.collection.models, function(eventColumnItem) {
        $(this.el).append(new EventColumnsListItemView({model: eventColumnItem}).render().el);
      }, this);
      return this;
    }
  });

  window.EventColumnsListItemView = Backbone.View.extend({
    tagName: 'option',
    template: _.template($('#tpl-event-column-list-item').html()),
    render: function(eventColumnItem) {
      this.$el.html(this.template(this.model.toJSON()));
      this.$el.attr('value', this.model.get('id'));
      return this;
    }
  });

  this.eventColumnsList = new EventColumnsCollection();
  this.eventColumnsListView = new EventColumnsListView({collection: this.eventColumnsList});
  this.eventColumnsList.fetch({
    success: function(collection, response) {
      // Seed data for EventColumnsCollection
      collection.add(new EventColumnModel({
        id: 1,
        name: 'Client'
      }));
      collection.add(new EventColumnModel({
        id: 2,
        name: 'Check'
      }));
      collection.add(new EventColumnModel({
        id: 3,
        name: 'Output'
      }));
      collection.each(function(model) {
        model.save();
      });
    },
    error: function(collection, response) {
      console.log('Error fetching event columns from local storage');
      console.log(collection);
      console.log(response);
    }
  });

  // Allow for re-ordering of event columns in the settingsModal
  $('#eventColumnBtnUp').bind('click', function() {
    $('#eventColumnsList option:selected').each(function() {
      var newPos = $('#eventColumnsList option').index(this) - 1;
      if (newPos > -1) {
        $('#eventColumnsList option')
          .eq(newPos)
          .before('<option value="'+$(this).val()+'" selected="selected">'+$(this).text()+'</option>');
        $(this).remove();
      }
    });
  });

  $('#eventColumnBtnAdd').bind('click', function() {
    var columnName = $('input#eventColumnName').val();
    var columnExists = $('#eventColumnsList:contains("'+columnName+'")').length;
    if (columnExists) {
      $(this).parents('.control-group').removeClass('success');
      $(this).parents('.control-group').addClass('error');
      $(this).parents('.controls')
        .children('p.help-block')
        .html('That column already exists!');
    } else {
      $(this).parents('.control-group').removeClass('error');
      $(this).parents('.control-group').addClass('success');
      $(this).parents('.controls')
        .children('p.help-block')
        .html('Column added!');
    }
  });

})(jQuery);
