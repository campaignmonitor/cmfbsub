(function (cmfbsub, $) {

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
          $("#body").find(".pref, h1, .page").hide();
          $("#body").show();
          var counter = 0;
          $("#body h1, .page").each(function() {
            counter++;
            $(this).delay(counter * 50).fadeIn(400);
          });
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

  function ready() {
    $("select").uniform();
    setupSignin();
  }
  
  cmfbsub.settings = {
    ready: ready
  };
})(window.cmfbsub = window.cmfbsub || {}, jQuery);