(function (cmfbsub, $) {

  var account = {},
      renderClientOptions,
      renderListOptions,
      renderListFields;

  function showPages() {
    $("#body").find(".pref, h1, .page").hide();
    $("#body").show();
    var counter = 0;
    $("#body h1, .page").each(function() {
      counter++;
      $(this).delay(counter * 50).fadeIn(400);
    });
  }

  function signIn() {
    $("#site-address-full").val(
      $("#site-address").val().indexOf(".") != -1 ?
        $("#site-address").val() : // Custom domain
        $("#site-address").val() + ".createsend.com"
    );
    $(".sign-in button").addClass('disabled').html('Logging in&hellip;');
    $.ajax({
      type: "POST",
      url: "/apikey",
      data: $("#loginform").serialize(),
      dataType: "json",
      success: function(data) {
        $(".sign-in.context-box").fadeOut(200, function() {
          $("button.sign-in").removeClass('selected').hide();
          account = data.account;
          setupClientOptions();
          showPages();
        });
      },
      error: function() {
        $(".sign-in .error.hidden").removeClass("hidden");
        $(".sign-in button").removeClass('disabled').html('Log in');
      }
    });
  }

  function setupSignin() {
    $("#loginform").submit(function() { return false; });
    $("#site-address").bind("keyup change", function() {
      if ($(this).val().indexOf(".") != -1) {
        $("menu.context-box").addClass("custom-domain");
      } else {
        $("menu.context-box").removeClass("custom-domain");
      }
    });
    $(".sign-in button").click(function() {
      signIn();
    });
  }

  function loadSavedForm($page, page_id) {
    if (!account.saved_forms || !account.saved_forms.forms || 
      !account.saved_forms.forms[page_id]) { return; }
    var sf = account.saved_forms.forms[page_id];
    var fields = account.saved_forms.fields[sf.id];
    var $prefs = $page.parent().find("div.prefs");
    var $clients = $prefs.find('select[id^="clients-"]'),
        $lists = $prefs.find('select[id^="lists-"]'),
        $fields = $prefs.find('fieldset[id^="fields-"]'),
        $intro = $prefs.find('input[id^="intromessage-"]'),
        $thanks = $prefs.find('input[id^="thanksmessage-"]');

    $clients.val(sf.client_id); // Select client
    loadListsForClient($lists, sf.client_id, function(lists) { // Load lists, and select
      if (!lists || lists.length === 0) { return; }
      // Indicate which list should be selected
      $.each(lists, function(i,l) { if (l.ListID === sf.list_id) { l.selected = true; }});
      $lists.html(renderListOptions({ lists: lists, selected: sf.list_id}));
      $lists.fadeIn(200)
      // Load list fields
      setupLists($lists);
      showListOptions($lists, sf.list_id, fields);
      // Set messages
      $intro.val(sf.intro_message);
      $thanks.val(sf.thanks_message);
    });
  }

  function selectPage($page) {
    var page_id = $page.attr("id").substring(5);
    $page.addClass('selected'); // Highlight it
    // Duplicate, absolutise and slide it up
    $page.absolute = $page.clone().insertBefore($page);
    $page.absolute.addClass('absolute');
    $page.absolute.absolutize();
    $page.fadeOut();
    $page.firstPosition = $("#body .page:first-of-type").position().top;
    $page.absolute.delay(300).animate({ top: $page.firstPosition + 'px' }, { duration: 300, easing: 'easeOutCubic' });
    $("#body .page:not(.absolute)").delay(300).fadeOut(400);
    $($page.parent().find(".prefs .pref")[0]).delay(100+500).fadeIn(300);
    $page.absolute.delay(500).addClass('arrowed');
    // Show back button
    $("#body .back").delay(300).fadeIn(1000);

    if (account.saved_forms && account.saved_forms.forms && account.saved_forms.forms[page_id]) {
      loadSavedForm($page, page_id);
    }
  }

  function deselectPage() {
    $("#body .page.absolute").remove();
    $("#body .page").removeClass("selected arrowed");
    $(".pref").hide();
    $("#body .back").hide();
    showPages();
  }

  function showListOptions($lists, list_id, saved_fields) {
    // Attempt to Load custom fields
    $.ajax({
      type: "GET",
      url: "/customfields/" + account.api_key + "/" + list_id,
      dataType: "json",
      success: function(fields) {
        if (saved_fields) {
          // Indicate which fields should be checked
          $.each(fields, function(i,f) {
            var checked = false;
            $.each(saved_fields, function(j,sf) {
              if (f.Key === sf.field_key) {
                checked = true;
                return;
              }
            });
            f.checked = checked;
          });
        }
        var $fields = $($lists.closest(".prefs").find(".pref")[1]).find("fieldset");
        $fields.html(renderListFields({ fields: fields }));
        var $prefs = $lists.closest('.prefs').find('.pref');
        $($prefs[1]).fadeIn(200); // List options
        $($prefs[2]).fadeIn(200); // Save
      }
    });
  }

  function hideListOptions($lists) {
    var $prefs = $lists.closest('.prefs').find('.pref');
    $($prefs[1]).hide(); // Options
    $($prefs[2]).hide(); // Save
  }

  function setupLists($lists) {
    $lists.change(function() {
      if ($(this).val() !== "nothing") {
        var list_id = $(this).attr("value");
        showListOptions($lists, list_id);
      } else {
        hideListOptions($lists);
      }
    });
  }

  function loadListsForClient($lists, client_id, successCallback) {
    $lists.hide();
    $.ajax({
      type: "GET",
      url: "/lists/" + account.api_key + "/" + client_id,
      dataType: "json",
      success: successCallback
    });
  }

  function getFormData($save) {
    var $prefs = $save.closest("div.prefs");
    var $clients = $prefs.find('select[id^="clients-"]'),
        $lists = $prefs.find('select[id^="lists-"]'),
        $fields = $prefs.find('fieldset[id^="fields-"]'),
        $intro = $prefs.find('input[id^="intromessage-"]'),
        $thanks = $prefs.find('input[id^="thanksmessage-"]');
    var page_id = $clients.attr("id").substring(8),
        client_id = $clients.val(),
        list_id = $lists.val(),
        intro_message = $intro.val(),
        thanks_message = $thanks.val();
    var form_data = {
      api_key: account.api_key,
      page_id: page_id,
      client_id: client_id,
      list_id: list_id,
      intro_message: intro_message,
      thanks_message: thanks_message
    };
    $fields.find("input").each(function(i, e) {
      if ($(e).is(":checked") === true) {
        form_data[$(e).attr("id")] = "checked";
      }
    });
    return form_data;
  }

  function saveSubscribeForm($save, form_data) {
    $save.addClass('disabled').html('Saving&hellip;');
    $.ajax({
      type: "POST",
      url: "/page/" + form_data.page_id,
      data: $.param(form_data),
      dataType: "json",
      success: function(data) {
        if (data.status == "success") {
          window.location = '/saved/' + form_data.page_id;
        } else {
          $save.removeClass('disabled').html('Save Form');
          // TODO: Communicate error...
        }
      },
      error: function() {
        $save.removeClass('disabled').html('Save Form');
        // TODO: Communicate error...
      }
    });
  }

  function setupSaveForm() {
    $('form[id^="messages-"]').validate({errorElement: "div"});
    $('form[id^="messages-"]').submit(function() { return false; });
    var $save = $("#body .prefs .save button");
    var $prefs = $save.closest("div.prefs");
    $save.click(function() {
      if (!$(this).closest(".prefs").find('form[id^="messages-"]').valid()) { return; }
      var form_data = getFormData($(this));
      saveSubscribeForm($(this), form_data);
    });
  }
  
  function setupClientOptions() {
    $('select[id^="clients-"]').html(
      renderClientOptions({ clients: account.clients}));

    if (account && account.clients && account.clients.length === 1) {
      // If there's only one client, skip client selection
      $('select[id^="clients-"]').each(function(i, e) {
        var $lists = $(e).closest(".wrapper").find("select.list");
        $(e).val(account.clients[0].ClientID); // Select the client
        var client_id = $(e).attr("value");
        $lists.empty(); // Then load the client's lists
        loadListsForClient($lists, client_id, function(lists) {
          if (!lists || lists.length === 0) { return; }
          $lists.html(renderListOptions({ lists: lists, selected: '' }));
          $lists.fadeIn(200)
          setupLists($lists);
          $(e).hide();
        });
      });
    }
  }
  
  function setupPages() {
    // Page selection behaviour
    $("#body .page").click(function() { selectPage($(this)); });
    $("span#otherpages a").click(function() { deselectPage(); });
    
    // Client selection behaviour
    setupClientOptions();

    $('select[id^="clients-"]').change(function() {
      var $lists = $(this).closest(".wrapper").find("select.list");
      hideListOptions($lists);
      if ($(this).val() !== "nothing") {
        var page_id = $(this).attr("id").substring(8);
        var client_id = $(this).attr("value");
        $lists.empty();
        loadListsForClient($lists, client_id, function(lists) {
          if (!lists || lists.length === 0) { return; }
          $lists.html(renderListOptions({ lists: lists, selected: '' }));
          $lists.fadeIn(200)
          setupLists($lists);
        });
      } else {
        $lists.empty().hide();
      }
    });
    setupSaveForm();

    // They've already saved their API key
    if (account.api_key) { showPages(); }
  }

  function setupRenderers() {
    Handlebars.registerHelper('attFriendlyKey', function(key) {
      return "cf-" + key.substring(1, key.length - 1);
    });
    renderClientOptions = Handlebars.compile($("#client-options-template").html());
    renderListOptions = Handlebars.compile($("#list-options-template").html());
    renderListFields = Handlebars.compile($("#list-fields-template").html());
  }
  
  function ready(data) {
    setupRenderers();
    setupSignin();
    if (data) { account = data.account; }
    setupPages();
  }

  cmfbsub.settings = {
    ready: ready,
    account: account
  };
})(window.cmfbsub = window.cmfbsub || {}, jQuery);