// remap jQuery to $
(function($){})(window.jQuery);

var alerts_crit, alerts_warn;

function fetchAlerts() {
  $.getJSON('/events', function(data) {

    alerts_crit = new Array();
    alerts_warn = new Array();

    for (var nodekey in data) {
      var node = data[nodekey];

      $.getJSON('/client/'+nodekey, function(client_data) {
        for (var a in node) {

          var dataObject = {
            client: nodekey,
            check: a,
            status: node[a]['status'],
            output: node[a]['output'],
            environment: 'rackspace',
            hostname: 'ip_10-20-10-20',
            address: client_data['address'],
            roles: client_data['subscriptions']
          };

          if (node[a]['status'] == 2 || node[a]['status'] == 3) {
            alerts_crit.push(dataObject);
          } else {
            alerts_warn.push(dataObject);
          }
        }

        $('#critEventTemplate').tmpl(alerts_crit).appendTo('table#alerts > tbody');
        $('#warnEventTemplate').tmpl(alerts_warn).appendTo('table#alerts > tbody');
        $('#eventDetailsTemplate').tmpl(alerts_crit).appendTo('#event_detail_modals');
        $('#eventDetailsTemplate').tmpl(alerts_warn).appendTo('#event_detail_modals');
        $('tr[rel*=leanModal]').leanModal({ top : 50 });
      });
    }
  });
}

/* trigger when page is ready */
$(document).ready(function () {

  fetchAlerts();

});


/* optional triggers

$(window).load(function() {

});

$(window).resize(function() {

});

*/
