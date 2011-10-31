(function (cmfbsub, $) {
  
  var config = {};
  
  function setupSubscribe() {
    $("form#subscribeform").submit(function() { return false; });
    $("button#subscribe").click(function() {
      $.ajax({
        type: "POST",
        url: "/subscribe/" + config.page_id,
        data: $("form#subscribeform").serialize(),
        dataType: "json",
        success: function(data) {
          if (data.status == "success") {
            $(".success p.info").html(data.message);
            $(".success").show().fadeTo(0,0).animate({top:'10%',opacity:1}, 1500, 'easeOutExpo');
            $('body > *:not(.success)').fadeOut(800);
          } else {
            $(".subscribe-error p.info").html(data.message);
            $(".subscribe-error").show().fadeTo(0,0).animate({top:'10%',opacity:1}, 1500, 'easeOutExpo');
          }
        },
        error: function() {
          $(".subscribe-error p.info").html(data.message);
          $(".subscribe-error").show().fadeTo(0,0).animate({top:'10%',opacity:1}, 1500, 'easeOutExpo');
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