// remap jQuery to $
(function($){})(window.jQuery);

var events;

function fetchAlerts() {
  $.getJSON('/events', function(data) {

    m_events = new Array();

    $('table#alerts > tbody').empty();
    $('#event_detail_modals').empty();

    for (var nodekey in data) {
      var node = data[nodekey];

      for (var a in node) {

        var dataObject = {
          client: nodekey,
          check: a,
          status: node[a]['status'],
          output: node[a]['output'],
        };

        if (m_events[node[a]['status']] == null) {
          m_events[node[a]['status']] = new Array();
        }

        m_events[node[a]['status']].push(dataObject);
      }
    }

    for (status in m_events) {
      for (a in m_events[status]) {
        var m_event = m_events[status][a];

        $('#eventTemplate').tmpl(m_event).prependTo('table#alerts > tbody');

        $('tr#' + m_event['client'] + '_' + m_event['check']).click(function() {
          // TODO: replace or clear & generate the contents of the modal dialog
        });
      }
    }

    $('tr[rel*=leanModal]').leanModal({ top : 50 });

  });
}

/* trigger when page is ready */
$(document).ready(function () {

  fetchAlerts();

  ws = new WebSocket("ws://" + location.hostname + ":9000");
  ws.onmessage = function(evt) {
    fetchAlerts();
  }

  // TODO: fix clipboard support
  /*$('div#event_details_modal > div.alert_detail_group > div.copy').click(function() {
    var currentVal = $(this).parent().find('div.alert_detail').children().last().text();

    $(this).zclip({
      path:'swf/ZeroClipboard.swf',
      copy:currentVal
    });
  });*/

});


/* optional triggers

$(window).load(function() {

});

$(window).resize(function() {

});

*/
