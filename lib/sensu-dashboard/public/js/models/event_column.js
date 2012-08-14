define(['backbone'], function(Backbone) {
  var model = Backbone.Model.extend({
    defaults: {
      id: 1,
      name: 'nil'
    }
  });

  return model;
});
