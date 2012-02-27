(function (cmfbsub, $) {
  
  var config = {};
  
  function prepareDateFields() {
    $("fieldset.date-fieldset").each(function () {
      var $year = $(this).find('select[id^="year-"]'),
          $month = $(this).find('select[id^="month-"]'),
          $day = $(this).find('select[id^="day-"]');
      $(this).find('input[id^="cf-"]').val($year.val() + "-" + $month.val() + "-" + $day.val());
    });
  }

  function setupSubscribe() {
    $("form#subscribeform").validate({errorElement: "div"});
    $("form#subscribeform").submit(function() { return false; });
    $("button#subscribe").click(function() {
      if (!$("form#subscribeform").valid()) { return; }
      prepareDateFields();
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
        error: function(xhr, status, error) {
          $("button#subscribe").removeClass('disabled').html('Subscribe');
          $(".subscribe-error p.info").text(data.message);
          $(".subscribe-error").show().fadeTo(0,0).animate({opacity:1}, 1500, 'easeOutExpo');
        }
      });
    });
  }

  function setupDateFieldSet($month, $day, $year) {
    var onDateValChange = function() {
      var year = $year.val(),
          month = $month.val();
      if ((year != 0) &&  (month!=0)) {
        var lastday = 32 - new Date(year, month - 1, 32).getDate(),
            selected_day = $day.val();
        // Change selected day if it is greater than the number of days in current month
        if (selected_day > lastday) {
          $day.find('option[value=' + selected_day + ']').attr('selected', false);
          $day.find('#dob_day  > option[value=' + lastday + ']').attr('selected', true);
        }
        // Remove possibly offending days
        for (var i = lastday + 1; i < 32; i++) {
          $day.find('option[value=' + i + ']').remove();  
        }
        // Add possibly missing days
        for (var i = 29; i < lastday + 1; i++) {
          if (!$day.find('option[value=' + i + ']').length) {
            $day.append($("<option></option>").attr("value",i).text(i));
          } 
        }
      }
    }
    $month.change(onDateValChange);
    $year.change(onDateValChange);
  }

  function setupDateFields() {
    var $fieldsets = $("fieldset.date-fieldset");
    $fieldsets.each(function () {
      var $month = $(this).find('select[id^="month-"]'),
          $day = $(this).find('select[id^="day-"]'),
          $year = $(this).find('select[id^="year-"]');
      setupDateFieldSet($month, $day, $year);
    });
  }

  function ready(data) {
    config = data;
    setupDateFields();
    setupSubscribe();
  }

  cmfbsub.subscribe_form = {
    ready: ready
  };
})(window.cmfbsub = window.cmfbsub || {}, jQuery);