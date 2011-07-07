/* Matthew's demo code. */

$(document).ready(function(){
   
   // Style dropdowns
   $("select").uniform();
   
   $(".sign-in button").click(function() {
     // Disable submit
     $(this).addClass('disabled').html('Logging in&hellip;');
     // Fade out log in box
     // The delay is for demo purposes
     $(".sign-in.context-box").delay(1000).fadeOut(200, function() { 
       // Undisable header button
       $("button.sign-in").removeClass('selected');
       // Hide next
       $("#body").find(".pref, h1, .page").hide();
       // Unhide next's container
       $("#body").show();
       // Transition to the next step.
       // Fade in each element slightly later than each other
       var counter = 0;
       $("#body h1, .page").each(function() {
         counter++;
         $(this).delay(counter*50).fadeIn(400);
       });
     });
   });
   
   $("#body .page").click(function() {
     // Highlight it
     page = $(this);
     page.addClass('selected');
     page.absolute = page.clone().insertBefore(page);
     page.absolute.addClass('absolute');
     page.absolute.absolutize();
     page.fadeTo(0,0);
     page.firstPosition = $("#body .page:first-of-type").position().top;
     page.absolute.delay(300).animate({top: page.firstPosition+'px'}, {duration: 300, easing: 'easeOutCubic'});
     $("#body .page:not(.absolute)").delay(300).fadeOut(400);
     // Fade in prefs
     var counter = 0;
     $("#body .pref").each(function() {
       counter++;
       $(this).delay((counter*100)+500).fadeIn(300);
     });
     page.absolute.delay(500).addClass('arrowed');
   });
   
});