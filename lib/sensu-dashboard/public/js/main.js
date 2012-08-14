require.config({
  paths: {
    jquery: 'libs/jquery/jquery-1.8.0.min',
    underscore: 'libs/underscore/underscore-min',
    backbone: 'libs/backbone/backbone-min',
    text: 'libs/require/text.min',
  },
  shim: {
    backbone: {
      deps: ['jquery', 'underscore'],
      exports: 'Backbone',
    },
    underscore: {
      exports: '_',
    },
  }
});

require([
  'underscore',
  'backbone',
  'app',
], function(_, Backbone, app) {
  app.init();
});

/*
jquery
bootstrap
json2
underscore
backbone
backbone.localStorage
main
events
*/
