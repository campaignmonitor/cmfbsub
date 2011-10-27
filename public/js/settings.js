(function (cmfbsub, $) {
  
  var account = {},
      renderListOptions;

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
    // Show first pref
    $($(".pref")[0]).delay(100+500).fadeIn(300);
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

  function loadListsForClient($lists, client_id) {
    $.ajax({
      type: "GET",
      url: "/lists/" + account.api_key + "/" + client_id,
      dataType: "json",
      success: function(lists) {
        if (!lists) { return; }
        $lists.html(renderListOptions({ lists: lists }));
        $lists.fadeIn(200)
        // Show the rest of the prefs
        var $prefs = $(this).closest('.prefs').find('.pref');
        $($prefs[1]).fadeIn(300);
        $($prefs[2]).delay(200).fadeIn(300);
      }
    });
  }
  
  function setupPages() {
    // Page selection behaviour
    $("#body .page").click(function() { selectPage($(this)); });
    $("span#otherpages a").click(function() { deselectPage(); });
    
    // Client selection behaviour
    $('select[id^="clients-"]').change(function() {
      var $lists = $(this).closest(".wrapper").find("select.list");
      if ($(this).val() !== "nothing") {
        var page_id = $(this).attr("id").substring(8);
        var client_id = $(this).attr("value");
        $lists.empty();
        loadListsForClient($lists, client_id);
      } else {
        $lists.empty().hide();
      }
    });
  }

  function setupRenderers() {
    renderListOptions = Handlebars.compile($("#list-options-template").html());
  }

  function ready(data) {
    setupRenderers();
    setupSignin();
    setupPages();
    if (data) {
      account = data.account;
      showPages(); // A CM account has already been saved for this user
    }
  }

  cmfbsub.settings = {
    ready: ready,
    account: account
  };
})(window.cmfbsub = window.cmfbsub || {}, jQuery);