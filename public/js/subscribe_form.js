(function (cmfbsub, $) {
  
  var config = {};

  function setupSubscribe() {
    $("form#subscribeform").validate({errorElement: "div"});
    $("form#subscribeform").submit(function() { return false; });
    $("button#subscribe").click(function() {
      if (!$("form#subscribeform").valid()) { return; }
      $("button#subscribe").addClass('disabled').html('Subscribing&hellip;');
      $.ajax({
        type: "POST",
        url: "/subscribe/" + config.page_id,
        data: $("form#subscribeform").serialize(),
        dataType: "json",
        success: function(data) {
          if (data.status == "success") {
            $(".success p.info").text(data.message);
            $(".success").show().fadeTo(0,0).animate({top:'2%',opacity:1}, 1500, 'easeOutExpo');
            $('body > *:not(.success)').fadeOut(800);
          } else {
            $(".subscribe-error p.info").text(data.message);
            $(".subscribe-error").show().fadeTo(0,0).animate({opacity:1}, 1500, 'easeOutExpo');
          }
          $("button#subscribe").removeClass('disabled').html('Subscribe');
        },
        error: function() {
          $("button#subscribe").removeClass('disabled').html('Subscribe');
          $(".subscribe-error p.info").text(data.message);
          $(".subscribe-error").show().fadeTo(0,0).animate({opacity:1}, 1500, 'easeOutExpo');
        }
      });
    });
  }

  function ready(data) {
    config = data;
    setupSubscribe();
  }

  cmfbsub.subscribe_form = {
    ready: ready
  };
})(window.cmfbsub = window.cmfbsub || {}, jQuery);