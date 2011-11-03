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
  
  function addValidators() {
    $.validator.addMethod(
    	"subscribeformdate", function(value, element) {
    		var check = false,
    		    re = /^\d{1,2}\/\d{1,2}\/\d{4}$/;
    		if( re.test(value)){
    			var adata = value.split('/'),
    			    gg = parseInt(adata[0],10),
    			    mm = parseInt(adata[1],10),
    			    aaaa = parseInt(adata[2],10),
    			    xdata = new Date(aaaa,mm-1,gg);
    			if ( ( xdata.getFullYear() == aaaa ) && ( xdata.getMonth () == mm - 1 ) && ( xdata.getDate() == gg ) )
    				check = true;
    			else
    				check = false;
    		} else
    			check = false;
    		return this.optional(element) || check;
    	},
    	"Please enter a valid date (dd/mm/yyyy)"
    );
  }

  function ready(data) {
    config = data;
    addValidators();
    setupSubscribe();
  }

  cmfbsub.subscribe_form = {
    ready: ready
  };
})(window.cmfbsub = window.cmfbsub || {}, jQuery);