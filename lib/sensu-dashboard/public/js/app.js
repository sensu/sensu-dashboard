define([
  'routers/router',
], function(Router) {
  var init = function() {
    this.router = new Router();
  };

  return {
    init: init
  };
});
