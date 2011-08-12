// remap jQuery to $
(function($){})(window.jQuery);

var alerts_crit, alerts_warn, alerts_unknown;

function fetchAlerts() {
  $.getJSON('/events', function(data) {

    alerts_crit = new Array();
    alerts_unknown = new Array();
    alerts_warn = new Array();

    $('table#alerts > tbody').empty();
    $('#event_detail_modals').empty();

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

          if (node[a]['status'] == 1) {
            alerts_warn.push(dataObject);
          }
          else if (node[a]['status'] == 2) {
            alerts_crit.push(dataObject);
          } else {
            alerts_unknown.push(dataObject);
          }
        }

        $('#critEventTemplate').tmpl(alerts_crit).appendTo('table#alerts > tbody');
        $('#unknownEventTemplate').tmpl(alerts_unknown).appendTo('table#alerts > tbody');
        $('#warnEventTemplate').tmpl(alerts_warn).appendTo('table#alerts > tbody');
        $('#eventDetailsTemplate').tmpl(alerts_crit).appendTo('#event_detail_modals');
        $('#eventDetailsTemplate').tmpl(alerts_unknown).appendTo('#event_detail_modals');
        $('#eventDetailsTemplate').tmpl(alerts_warn).appendTo('#event_detail_modals');
        $('tr[rel*=leanModal]').leanModal({ top : 50 });

        // Add events to the generated templates
        for (var a in alerts_crit) {
          var identifier = alerts_crit[a]['client']+'_'+alerts_crit[a]['check'];
          addClipboardToDetails(identifier);
        }
        for (var a in alerts_unknown) {
          var identifier = alerts_unknown[a]['client']+'_'+alerts_unknown[a]['check'];
          addClipboardToDetails(identifier);
        }
        for (var a in alerts_warn) {
          var identifier = alerts_warn[a]['client']+'_'+alerts_warn[a]['check'];
          addClipboardToDetails(identifier);
        }
      });
    }
  });
}

function addClipboardToDetails(identifier) {

  $('div#'+identifier+'_modal > div.alert_detail_group > div.copy').click(function() {
    var currentVal = $(this).parent().find('div.alert_detail').children().last().text();

    $(this).zclip({
      path:'swf/ZeroClipboard.swf',
      copy:currentVal
    });
  });

}

/* trigger when page is ready */
$(document).ready(function () {

  fetchAlerts();

  ws = new WebSocket("ws://" + location.hostname + ":9000");
  ws.onmessage = function(evt) {
    fetchAlerts();
  }

});


/* optional triggers

$(window).load(function() {

});

$(window).resize(function() {

});

*/
