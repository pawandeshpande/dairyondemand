

var $error = $("#dod-error");
var $dodbusyindicator = $(".dod-busy-indicator"), $formsignin = $(".form-signin"), spinner;

var opts = {
  lines: 13 // The number of lines to draw
, length: 28 // The length of each line
, width: 14 // The line thickness
, radius: 42 // The radius of the inner circle
, scale: 1 // Scales overall size of the spinner
, corners: 1 // Corner roundness (0..1)
, color: '#000' // #rgb or #rrggbb or array of colors
, opacity: 0.25 // Opacity of the lines
, rotate: 0 // The rotation offset
, direction: 1 // 1: clockwise, -1: counterclockwise
, speed: 1 // Rounds per second
, trail: 60 // Afterglow percentage
, fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
, zIndex: 2e9 // The z-index (defaults to 2000000000)
, className: 'spinner' // The CSS class to assign to the spinner
, top: '50%' // Top position relative to parent
, left: '50%' // Left position relative to parent
, shadow: false // Whether to render a shadow
, hwaccel: false // Whether to use hardware acceleration
, position: 'absolute' // Element positioning
};
var $busyindicator = document.getElementById('busy-indicator')
spinner = new Spinner(opts).spin();




$.ajaxSetup({
    	beforeSend: function(){
	    $busyindicator.appendChild(spinner.el);
	},
	complete: function(){
   	    $busyindicator.removeChild(spinner.el);
	}
})

    
$formsignin.submit ( function() {
    $formsignin.hide();
    $.ajax({
	type: "POST",
	url: $formsignin.attr("action"),
	data: $formsignin.serialize(),
	error:function(){
	$error.show();
	},
   	success: function(data){ window.location="/dodcustindex";}
    })
    return false;
    
})

/*$form.submit ( function() {
    
    $.ajax({
	type: "POST",
	url: $formproduct.attr("action"),
	data: $formproduct.serialize(),
	error:function(){
	$error.show();
	},
   	success: function(data){  window.location="/dodcustindex";}
    })
    return false;
    
})*/


$('form').on('submit', function (e) {
    var theForm = $(this);

      $.ajax({
            type: 'POST',
          url: $(theForm).attr("action"), 
            data: $(theForm).serialize(),
            success: function () {
		console.log("success in form");
		location.reload();                   
            }
      });
      e.preventDefault();});

	    
	
	
