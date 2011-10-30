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
    $("#site-address-full").val($("#site-address").val() + ".createsend.com");
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
          $('select[id^="clients-"]').html(
            renderClientOptions({ clients: account.clients}));
          showPages();
        });
      },
      error: function() {
        $(".sign-in .error.hidden").removeClass("hidden");
        $(".sign-in button").removeClass('disabled').html('Log in');
      },
    });
  }

  function setupSignin() {
    $("#loginform").submit(function() { return false; });
    $(".sign-in button").click(function() {
      signIn();
    });
  }
  
  function selectPage($page) {
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
    // Add arrow
    $page.absolute.delay(500).addClass('arrowed');
    // Show back button
    $("#body .back").delay(300).fadeIn(1000);
  }

  function deselectPage() {
    $("#body .page.absolute").remove();
    $("#body .page").removeClass("selected arrowed");
    $(".pref").hide();
    $("#body .back").hide();
    showPages();
  }

  function loadListCustomFields($lists, list_id) {
    var $fields = $($lists.closest(".prefs").find(".pref")[1]).find("fieldset");
    $.ajax({
      type: "GET",
      url: "/customfields/" + account.api_key + "/" + list_id,
      dataType: "json",
      success: function(fields) {
        var has_fields = (fields && fields.length > 0);
        if (has_fields) {
          $fields.html(renderListFields({ fields: fields }));
        }
        showListOptions($lists, has_fields);
      }
    });
  }

  function showListOptions($lists, show_fields) {
    var $prefs = $lists.closest('.prefs').find('.pref');
    if (show_fields) {
      $($prefs[1]).fadeIn(200); // Fields
    } else {
      $($prefs[1]).hide();
    }
    $($prefs[2]).fadeIn(200); // Save
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
        loadListCustomFields($lists, list_id);
      } else {
        hideListOptions($lists);
      }
    });
  }

  function loadListsForClient($lists, client_id) {
    $lists.hide();
    $.ajax({
      type: "GET",
      url: "/lists/" + account.api_key + "/" + client_id,
      dataType: "json",
      success: function(lists) {
        if (!lists || lists.length === 0) { return; }
        $lists.html(renderListOptions({ lists: lists }));
        $lists.fadeIn(200)
        setupLists($lists);
      }
    });
  }

  function getFormData($save) {
    var $prefs = $save.closest("div.prefs");
    var $clients = $prefs.find('select[id^="clients-"]'),
        $lists = $prefs.find('select[id^="lists-"]'),
        $fields = $prefs.find('fieldset[id^="fields-"]');
    var page_id = $clients.attr("id").substring(8),
        list_id = $lists.val();
    var form_data = {
      api_key: account.api_key,
      page_id: page_id,
      list_id: list_id
    };
    $fields.find("input").each(function(i, e) {
      if ($(e).is(":checked") === true) {
        form_data[$(e).attr("id")] = "checked";
      }
    });
    return form_data;
  }

  function saveSubscribeForm(form_data) {
    $.ajax({
      type: "POST",
      url: "/page/" + form_data.page_id,
      data: $.param(form_data),
      dataType: "json",
      success: function(data) {
        if (data.status == "success") {
          if (data.app_add_url == '') {
            window.location = "/";
          } else {
            top.location = data.app_add_url;
          }
        } else {
          // TODO: Communicate error...
        }
      },
      error: function() {
        // TODO: Communicate error...
      }
    });
  }

  function setupSaveForm() {
    var $save = $("#body .prefs .save button");
    $save.click(function() {
      var form_data = getFormData($(this));
      saveSubscribeForm(form_data);
    });
  }
  
  function setupPages() {
    // Page selection behaviour
    $("#body .page").click(function() { selectPage($(this)); });
    $("span#otherpages a").click(function() { deselectPage(); });
    
    // Client selection behaviour
    $('select[id^="clients-"]').html(
      renderClientOptions({ clients: account.clients}));
    $('select[id^="clients-"]').change(function() {
      var $lists = $(this).closest(".wrapper").find("select.list");
      hideListOptions($lists);
      if ($(this).val() !== "nothing") {
        var page_id = $(this).attr("id").substring(8);
        var client_id = $(this).attr("value");
        $lists.empty();
        loadListsForClient($lists, client_id);
      } else {
        $lists.empty().hide();
      }
    });
    setupSaveForm();

    // A CM account has already been saved for this user
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