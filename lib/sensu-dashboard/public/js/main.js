require.config({
  paths: {
    jquery: 'libs/jquery/jquery-1.8.0.min',
    underscore: 'libs/underscore/underscore-min',
    backbone: 'libs/backbone/backbone-min',
    text: 'libs/require/text.min',
    bootstrap: 'libs/bootstrap/bootstrap.min',
  },
  shim: {
    backbone: {
      deps: ['jquery', 'underscore'],
      exports: 'Backbone',
    },
    underscore: {
      exports: '_',
    },
    bootstrap: {
      deps: ['jquery'],
    },
  },
});

require([
  'jquery',
  'underscore',
  'backbone',
  'bootstrap',
  'app',
], function($, _, Backbone, bootstrap, app) {
  // Force application/json accept header for all jQuery AJAX requests
  $.ajaxSetup({
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json'
    }
  });

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
