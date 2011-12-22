// remap jQuery to $
(function($){})(window.jQuery);

Object.size = function(obj) {
  var size = 0, key;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) size++;
  }
  return size;
};

var selected_filters = {};
var grouped_filters = {};

var filter_unknown_checks = true;

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

function fetchEvents() {
  var event_count = 0;

  $.getJSON('/events.json', function(data) {
    var m_events = new Array();

    $('table#events > tbody').empty();

    // iterate through the filters
    grouped_filters = {};
    for (var i in selected_filters) {
      var current_filter = selected_filters[i];
      
      // store client filters in the grouped filters array
      if (current_filter['type'] == 'client') {
        grouped_filters['client'] || (grouped_filters['client'] = []);
        for (var j in current_filter['value']) {
          grouped_filters['client'].push(current_filter['value'][j]);
        }
      }
      
      // store subscription filters in the grouped filters array
      if (current_filter['type'] == 'subscription') {
        grouped_filters['subscription'] || (grouped_filters['subscription'] = []);
        for (var j in current_filter['value']) {
          grouped_filters['subscription'].push(current_filter['value'][j]);
        }
      }
      
      // store check filters in the grouped filters array
      if (current_filter['type'] == 'check') {
        grouped_filters['check'] || (grouped_filters['check'] = []);
        for (var j in current_filter['value']) {
          grouped_filters['check'].push(current_filter['value'][j]);
        }
      }
      
      // store status filters in the grouped filters array
      if (current_filter['type'] == 'status') {
        grouped_filters['status'] || (grouped_filters['status'] = []);
        for (var j in current_filter['value']) {
          grouped_filters['status'].push(current_filter['value'][j]);
        }
      }
    }

    // iterate through each node
    for (var nodekey in data) {
      // skip node if client filters exist and the client is not in the filter
      if ((Object.size(grouped_filters['client']) > 0) && ($.inArray(nodekey, grouped_filters['client']) == -1)) {
        continue;
      }
      
      // skip node if subscription filters exist and the subscription is not in the filter
      if ((Object.size(grouped_filters['subscription']) > 0) && ($.inArray(nodekey, grouped_filters['subscription']) == -1)) {
        continue;
      }
      
      var node = data[nodekey];

      // iterate through each event for the current node
      for (var a in node) {
        // skip unknown checks if the checkbox is enabled
        if (filter_unknown_checks && (node[a]['output'] == 'Unknown check')) {
            continue;
        }
        
        // skip event if check filters exist and the check is not in the filter
        if ((Object.size(grouped_filters['check']) > 0) && ($.inArray(a, grouped_filters['check']) == -1)) {
          continue;
        }
        
        // skip event if status filters exist and the status is not in the filter
        if ((Object.size(grouped_filters['status']) > 0) && ($.inArray(node[a]['status'], grouped_filters['status']) == -1)) {
          continue;
        }
        
        // if a status code does not exist, set it to unknown
        node[a]['status'] || (node[a]['status'] = 3);
        
        // if an output does not exist, set it to "nil"
        node[a]['output'] || (node[a]['output'] = "nil output");

        var is_unknown = node[a]['status'] >= 3 || node[a]['status'] < 0;

        event_count++;
        var dataObject = {
          identifier: SHA1(nodekey+a),
          client: nodekey,
          check: a,
          status: node[a]['status'],
          output: node[a]['output'],
          occurrences: node[a]['occurrences'],
          is_unknown: is_unknown
        };

        if (!m_events[node[a]['status']]) {
          m_events[node[a]['status']] = [];
        }

        m_events[node[a]['status']][nodekey+a] = dataObject;
      }
    }
    for (var status in m_events) {
      for (var a in m_events[status]) {
        var m_event = m_events[status][a];
        var ccheck = m_event['client'] + m_event['check'];

        $('#eventTemplate').tmpl(m_event).prependTo('table#events > tbody');

        $('tr#' + SHA1(ccheck)).click(function() {
          $('div#event_details_modal > div#event_data').empty();
          $('div#event_details_modal > div#client_data').empty();
          var selectedStatus = $(this).children('td#status').html();
          var selectedNodeKey = $(this).children('td#client').html() + $(this).children('td#check').html();
          var selectedEvent = m_events[selectedStatus][selectedNodeKey];
          $('#eventDetailsRowTemplate').tmpl(selectedEvent).appendTo('div#event_details_modal > div#event_data');

          var client_alert_img = $("#disable_client_alerts").children().first();
          $.ajax({
            url: '/stash/silence/'+selectedEvent['client']+'.json',
            success: function(data, textStatus, xhr) {
              if(xhr.status == 200) {
                client_alert_img.attr("src", "/img/megaphone_icon_off.png");
              }
            },
            error: function(xhr, textStatus, errorThrown) {
              if(xhr.status == 404) {
                client_alert_img.attr("src", "/img/megaphone_icon.png");
              }
            }});

          var event_alert_img = $("#disable_client_check_alerts").children().first();
          $.ajax({
            url: '/stash/silence/'+selectedEvent['client']+'/'+selectedEvent['check']+'.json',
            success: function(data, textStatus, xhr) {
              if(xhr.status == 200) {
                event_alert_img.attr("src", "/img/megaphone_icon_off.png");
              }
            },
            error: function(xhr, textStatus, errorThrown) {
              if(xhr.status == 404) {
                event_alert_img.attr("src", "/img/megaphone_icon.png");
              }
            }});

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

    $('span#event_count').html(event_count);
  });
}

function fetchClients() {
  $.getJSON('/clients.json', function(data) {

    m_clients = new Array();

    $('table#clients > tbody').empty();

    // iterate through the filters
    grouped_filters = {};
    for (var i in selected_filters) {
      var current_filter = selected_filters[i];
      
      // store client filters in the grouped filters array
      if (current_filter['type'] == 'client') {
        grouped_filters['client'] || (grouped_filters['client'] = []);
        for (var j in current_filter['value']) {
          grouped_filters['client'].push(current_filter['value'][j]);
        }
      }
      
      // store subscription filters in the grouped filters array
      if (current_filter['type'] == 'subscription') {
        grouped_filters['subscription'] || (grouped_filters['subscription'] = []);
        for (var j in current_filter['value']) {
          grouped_filters['subscription'].push(current_filter['value'][j]);
        }
      }
    }

    // iterate through each node
    for (var clientkey in data) {
      var client = data[clientkey];
      
      // skip node if client filters exist and the client is not in the filter
      if ((Object.size(grouped_filters['client']) > 0) && ($.inArray(client['name'], grouped_filters['client']) == -1)) {
        continue;
      }

      // skip node if subscription filters exist and the subscription is not in the filter
      if ((Object.size(grouped_filters['subscription']) > 0) && ($.inArray(client['name'], grouped_filters['subscription']) == -1)) {
        continue;
      }

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
  });
}

function fetchStashes() {
  $.ajax({
    type: 'GET',
    url: '/stashes.json',
    success: function(data, textStatus, xhr) {
      $.ajax({
        type: 'POST',
        url: '/stashes.json',
        data: JSON.stringify(data),
        success: function(stash_data, textStatus, xhr) {
          stashes = new Array();
          for (var stash in stash_data) {
            stash_keys = new Array();
            stash_values = new Array();
            for (var stash_value in stash_data[stash]) {
              stash_keys.push(stash_value);
              stash_values.push({
                name: stash_value,
                value: stash_data[stash][stash_value]
              });
            }
            stashes.push({
              identifier: SHA1(stash),
              name: stash,
              keys: stash_keys.join(', '),
              values: stash_values
            });
          }
          $('table#events > tbody').empty();
          $('#stashTemplate').tmpl(stashes).appendTo('table#events > tbody');
          $('tbody > tr').click(function() {
            $('div#event_details_modal').empty();
            var row = $(this).parent().children().index($(this));
            $('#stashDetailsTemplate').tmpl(stashes[row]).appendTo('div#event_details_modal');
            $('div#delete_stash').click(function() {
              $('div#delete_stash > img').attr("src", "/img/loading_circle.gif");
              $.ajax({
                type: 'DELETE',
                url: '/stash/'+stashes[row]['name']+'.json',
                success: function(data, textStatus, xhr) {
                  $("#lean_overlay").fadeOut(200);
                  $("#event_details_modal").css({'display':'none'});
                  fetchStashes();
                },
                error: function(xhr, textStatus, errorThrown) {
                  $('div#delete_stash > img').attr("src", "/img/cross.png");
                  console.log('XHR: ' + xhr);
                  console.log('textStatus: ' + textStatus);
                  console.log('errorThrown: ' + errorThrown);
                  alert('Error deleting stash');
                }
              });
            });
          });
          $('tr[rel*=leanModal]').leanModal({ top : 50, bottom : 50 });
        },
        error: function(xhr, textStatus, errorThrown) {
          console.log('XHR: ' + xhr);
          console.log('textStatus: ' + textStatus);
          console.log('errorThrown: ' + errorThrown);
          alert('Error retrieving stashes');
        }
     });
    },
    error: function(xhr, textStatus, errorThrown) {
      console.log('XHR: ' + xhr);
      console.log('textStatus: ' + textStatus);
      console.log('errorThrown: ' + errorThrown);
      alert('Error retrieving stashes');
    }
  });
}

/* trigger when page is ready */
$(document).ready(function() {

  $(document).keyup(function(e) {
    if (e.keyCode == 27) { // esc
      $("#lean_overlay").fadeOut(200);
      $("#event_details_modal").css({'display':'none'});
    }
  });

  // TODO: fix clipboard support
  /*$('div#event_details_modal > div.event_detail_group > div.copy').click(function() {
    var currentVal = $(this).parent().find('div.event_detail').children().last().text();

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
