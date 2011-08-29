// remap jQuery to $
(function($){})(window.jQuery);

function capitaliseFirstLetter(string) {
  var newStr = '';
  var splitStr = string.split(' ');
  for (var word in splitStr) {
    newStr += splitStr[word].charAt(0).toUpperCase() + splitStr[word].slice(1) + ' ';
  }
  return newStr;
}

function sortEvents(a,b) {
  return a - b;
}

function fetchAlerts() {
  $.getJSON('/events.json', function(data) {

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

        if (m_events[node[a]['status'][nodekey+a]] == null) {
          m_events[node[a]['status'][nodekey+a]] = new Array();
        }

        m_events[node[a]['status'][nodekey+a]].push(dataObject);
      }
    }

    m_events.sort(sortEvents);

    for (status in m_events) {
      for (a in m_events[status]) {
        var m_event = m_events[status][a];
        var ccheck = m_event['client'] + m_event['check'];

        $('#eventTemplate').tmpl(m_event).prependTo('table#alerts > tbody');

        $('tr#' + ccheck).click(function() {
          $('div#event_details_modal > div#event_data').empty();
          $('div#event_details_modal > div#client_data').empty();
          $('#eventDetailsRowTemplate').tmpl(m_event).appendTo('div#event_details_modal > div#event_data');
          $.getJSON('/client/'+m_event['client']+'.json', function(clientdata) {
            $('#clientDetailsRowTemplate').tmpl(clientdata).appendTo('div#event_details_modal > div#client_data');
            $('div#event_details_modal > div#client_data > h1').click(function() {
              $(this).select();
            });
          });
        });
      }
    }

    $('tr[rel*=leanModal]').leanModal({ top : 50 });

    var row_count = $('table#alerts > tbody > tr').length;
    $('span#alert_count').html(row_count);

  });
}

function fetchClients() {
  $.getJSON('/clients.json', function(data) {

    m_clients = new Array();

    $('table#clients > tbody').empty();

    for (var clientkey in data) {
      var client = data[clientkey];
      client['subscriptions'] = client['subscriptions'].join(', ');
      m_clients.push(client);
    }

    $('#clientTemplate').tmpl(m_clients).prependTo('table#clients > tbody');

    var row_count = $('table#clients > tbody > tr').length;
    $('span#client_count').html(row_count);
  });
}

/* trigger when page is ready */
$(document).ready(function () {

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
