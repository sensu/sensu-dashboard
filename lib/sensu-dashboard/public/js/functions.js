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

        m_events[node[a]['status']][nodekey+a] = dataObject;
      }
    }

    for (status in m_events) {
      for (a in m_events[status]) {
        var m_event = m_events[status][a];
        var ccheck = m_event['client'] + m_event['check'];

        $('#eventTemplate').tmpl(m_event).prependTo('table#alerts > tbody');

        $('tr#' + ccheck).click(function() {
          $('div#event_details_modal > div#event_data').empty();
          $('div#event_details_modal > div#client_data').empty();
          var selectedStatus = $(this).children('td#status').html();
          var selectedNodeKey = $(this).attr('id');
          var selectedEvent = m_events[selectedStatus][selectedNodeKey];
          $('#eventDetailsRowTemplate').tmpl(selectedEvent).appendTo('div#event_details_modal > div#event_data');
          $.getJSON('/client/'+selectedEvent['client']+'.json', function(data) {
            var client = data;
            client['subscriptions'] = client['subscriptions'].join(', ');
            $('#clientDetailsRowTemplate').tmpl(client).appendTo('div#event_details_modal > div#client_data');
            $('div#event_details_modal > div#client_data > h1').click(function() {
              $(this).select();
            });
          });
        });
      }
    }

    $('tr[rel*=leanModal]').leanModal({ top : 50, bottom : 50 });

    var row_count = $('table#alerts > tbody > tr').length;
    $('span#alert_count').html(row_count);

    addTableSorting();
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

    $('tbody > tr').click(function() {
      $('div#event_details_modal > div#client_data').empty();

      var client_id = $(this).children('td#client_id').html();

      $.getJSON('/client/'+client_id+'.json', function(clientdata) {
        $('#clientDetailsRowTemplate').tmpl(clientdata).appendTo('div#event_details_modal > div#client_data');
      });
    });

    $('tr[rel*=leanModal]').leanModal({ top : 50, bottom : 50 });
    var row_count = $('table#clients > tbody > tr').length;
    $('span#client_count').html(row_count);

    addTableSorting();
  });
}

function addTableSorting() {
  var table = $('table');

  $('table > thead > tr > td').each(function() {
    var td = $(this),
      tdIndex = td.index(),
      inverse = false;

    td.click(function() {
      table.find('tbody').find('td').filter(function() {
        return $(this).index() === tdIndex;
      }).sortElements(function(a, b) {
        return $.text([a]) > $.text([b]) ?
          inverse ? -1 : 1
          : inverse ? 1 : -1
      }, function() {
        return this.parentNode;
      });
      inverse = !inverse;
    });
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
