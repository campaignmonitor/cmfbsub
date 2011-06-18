var messages = {
  no_clients_found: "Sorry, we couldn't find any clients in your Campaign Monitor account.",
  no_lists_found: "Sorry, we couldn't find any lists for your client.",
  list_not_found: "Sorry, we couldn't find that list for your client."
};

Config = null;

function facebookInit(config) {
  Config = config;
  FB.init({
    appId: Config.appId,
    xfbml: true
  });
  FB.Canvas.setAutoResize();
  if (window == top) { goHome(); }
}

function goHome() {
  top.location = 'http://apps.facebook.com/' + Config.canvasName + '/';
}

function showErrorMessage(msg) {
  $("#message").html(msg).show();
}

function setupSelectClient(api_key) {
  $(".errormessagebox").hide();
  $("#clients-list").empty();
  $("#clients").hide();
  $("#lists").hide();
  $.ajax({
    type: "GET",
    url: "/clients/" + api_key,
    dataType: "json",
    success: function(data) {
      if (data.length == 0) {
        showErrorMessage(messages.no_clients_found);
      } else if (data.length == 1) {
        setupSelectList(
          api_key, data[0].ClientID, data[0].Name);
      } else {
        $.each(data, function(i, c) {
          $("#clients-list").append("<p><a id=\"" + c.ClientID + "\" href=\"#\">" + c.Name + "</a></p>");
        });
        $("#clients-list a").click(function() {
          var client_id = $(this).attr("id");
          var client_name = $(this).val();
          setupSelectList(api_key, client_id, client_name);
        });
        $("#clients").show();
        $("#first-step").hide();
      }
    },
    error: function() {
      showErrorMessage(messages.no_clients_found);
    }
  });
}

function setupSelectList(api_key, client_id, client_name) {
  $(".errormessagebox").hide();
  $("#lists-list").empty();
  $("#lists").hide();
  $("#clients").hide();
  $.ajax({
    type: "GET",
    url: "/lists/" + api_key + "/" + client_id,
    dataType: "json",
    success: function(data) {
      if (data.length == 0) {
        showErrorMessage(messages.no_lists_found);
      } else if (data.length == 1) {
        setupListOptions(
          api_key, data[0].ListID, data[0].Name);
      } else {
        $.each(data, function(i, l) {
          $("#lists-list").append("<p><a id=\"" + l.ListID + "\" href=\"#\">" + l.Name + "</a></p>");
        });
        $("#lists-list a").click(function() {
          var list_id = $(this).attr("id");
          var list_name = $(this).val();
          setupListOptions(api_key, list_id, list_name);
        });
        $("#lists").show();
      }
    },
    error: function() {
      showErrorMessage(messages.no_lists_found);
    }
  });
}

function attFriendlyKey(key) {
  return "cf-" + key.substring(1, key.length - 1);
}

function setupListOptions(api_key, list_id, list_name) {
  $(".errormessagebox").hide();
  $("#custom-fields-list").empty();
  $("#lists").hide();
  $("#clients").hide();
  $("#listid").val(list_id);
  $.ajax({
    type: "GET",
    url: "/customfields/" + api_key + "/" + list_id,
    dataType: "json",
    success: function(data) {
      if (data.length > 0) {
        $.each(data, function(i, cf) {
          var afk = attFriendlyKey(cf.Key);
          var cfui = '<p>';
          cfui += '<input id="' + afk + '" name="' + afk + '" type="checkbox" value="' + afk + '"/>';
          cfui += '<span>' + cf.FieldName + ' (' + cf.DataType + ')</span>';
          cfui += '</p>';
          $("#custom-fields-list").append(cfui);
        });
        $("#custom-fields").show();
      }
    },
    error: function() {
      showErrorMessage(messages.list_not_found);
    }
  });
  $("#list-options").show();
}

function saveSubscribeForm(page_id) {
  $.ajax({
    type: "POST",
    url: "/page/" + page_id,
    data: $("#page").serialize(),
    dataType: "json",
    success: function(data) {
      if (data.status == "success") {
        window.location = "/";
      } else {
        showErrorMessage(data.message);
      }
    },
    error: function() {
      showErrorMessage("Sorry, something went wrong while saving your subscribe form. Please try again.");
    }
  });
}

$(document).ready(function() {
  $("a#get-clients").click(function() {
    setupSelectClient($("#apikey").val());
    return false;
  });
  $("#list-options a#save").click(function() {
    saveSubscribeForm($(this).attr("page_id"));
    return false;
  });
});
