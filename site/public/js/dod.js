var $busyindicator = document.getElementById('busy-indicator');
var $error = document.getElementById('hhub-error');
var $success = document.getElementById('hhub-success');
var  $formcustsignin = $(".form-custsignin"),  $formvendsignin = $(".form-vendorsignin");
var $pricingform = $(".form-hhubnewcompanyemail");

// Create a generic JQuery AJAX function

var ajaxCallParams = {};
var ajaxDataParams = {}; 

// General function for all ajax calls
function ajaxCall(callParams, dataParams, callback) {   
    $.ajax({
        type: callParams.Type,
        url: callParams.Url,
        quietMillis: 100,
        dataType: callParams.DataType,
        data: dataParams,
        cache: true,
        success:function (response) {
            callback(response);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            if (jqXHR.status > 400){
		displayError("#hhub-error", jqXHR.responseText);
		console.log("HTTP Error Code" + jqXHR.status);
		console.log("Error Status: "+ textStatus);
		console.log("Error Thrown: "+ errorThrown);
	    }}
    });
}


$(document).ready(function () {
    $.ajaxSetup({
    	beforeSend: function(){
    	    $busyindicator.appendChild(spinner.el);
	},
	complete: function(){
   	    $busyindicator.removeChild(spinner.el);
	}
    });
});


function pincodecheck (pincodefield, cityfield, statefield, areafield){
     var city = cityfield;
    var pincode = pincodefield.val();
    var state = statefield;
    var localarea = areafield;
    
    if (pincode.length  == 6){
	ajaxCallParams.Type = "GET"; 
	ajaxCallParams.Url = "/hhub/hhubpincodecheck";
	ajaxCallParams.DataType = "JSON"; // Return data type e-g Html, Json etc
	
	// Set Data parameters
	ajaxDataParams.pincode = pincode; 
        
	// Passing call and data parameters to general Ajax function
	ajaxCall(ajaxCallParams, ajaxDataParams, function (retdata) {
	   
	    if(retdata['success'] != 0){
		console.log(retdata);
		var data = retdata['result'];
		city.val(data[0].city);
		state.val(data[0].state);
		localarea.text(data[0].area);
	    }
	    else
	    {
		city.val("");
		state.val("");
		localarea.text("");
	    }
		
	});
    }

}

$(document).ready(function() {
    $('#shipzipcode').keyup(function(){
        pincodecheck($('#shipzipcode'),$('#shipcity'), $('#shipstate'), $('#areaname'));
    });
});


$(document).ready(function() {
    $('#cmpzipcode').keyup(function(){
        pincodecheck($('#cmpzipcode'), $('#cmpcity'), $('#cmpstate'), $('#areaname'));
    });
});



$pricingform.submit(function(e){
    var theForm = $(this);
    $(theForm).find("button[type='submit']").hide();
    ajaxCallParams.Type = "POST"; // POST type function 
    ajaxCallParams.Url = $(theForm).attr("action"); // Pass Complete end point Url e-g Payment Controller, Create Action
    ajaxCallParams.DataType = "HTML"; // Return data type e-g Html, Json etc
    
    // Set Data parameters
    ajaxDataParams = $(theForm).serialize();
    
    // Passing call and data parameters to general Ajax function
    ajaxCall(ajaxCallParams, ajaxDataParams, function (result) {
	window.location.replace("/hhub/hhubnewcompreqemailsent");
	displaySuccess("#hhub-success",result);
    });
    e.preventDefault();
});




function displaybillingaddress (){
    if( document.getElementById('billsameasshipchecked').checked ){
	$('#billingaddressrow').hide();
	clearbilltoaddress();
    }else
    {
	//copyshiptobillto();
	$('#billingaddressrow').show();
    }
}

function displaygstdetails () {
    if( document.getElementById('claimitcchecked').checked ){
	$('#gstdetailsfororder').show();
    }else
    {
	$('#gstdetailsfororder').hide();
    }

}


function clearbilltoaddress(){
    var billaddress = document.getElementById("billaddress");
    var billzipcode = document.getElementById("billzipcode");
    var billcity = document.getElementById("billcity");
    var billstate = document.getElementById("billstate");
    billaddress.value = "";
    billzipcode.value = "";
    billcity.value = "";
    billstate.value = ""; 
}


function copyshiptobillto()
{
    var shipaddress  = document.getElementById("shipaddress");
    var billaddress = document.getElementById("billaddress");
    var shipzipcode = document.getElementById("shipzipcode");
    var billzipcode = document.getElementById("billzipcode");
    var shipcity = document.getElementById("shipcity");
    var billcity = document.getElementById("billcity");
    var shipstate = document.getElementById("shipstate");
    var billstate = document.getElementById("billstate");
    
    billaddress.value = shipaddress.value;
    billzipcode.value = shipzipcode.value;
    billcity.value = shipcity.value;
    billstate.value = shipstate.value;
    
}


$( ":text" ).each(function( index ) {
    $( this ).focusout(function() {
      var text = $(this).val();
      text = $.trim(text);
      $(this).val(text);
    });
});


const copyToClipboard = str => {
  const el = document.createElement('textarea');
  el.value = str;
  el.setAttribute('readonly', '');
  el.style.position = 'absolute';
  el.style.left = '-9999px';
  document.body.appendChild(el);
  const selected =
    document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : false;
  el.select();
  document.execCommand('copy');
  document.body.removeChild(el);
  if (selected) {
    document.getSelection().removeAllRanges();
    document.getSelection().addRange(selected);
  }
};


function getCookie(k)
{
    var v=document.cookie.match('(^|;) ?'+k+'=([^;]*)(;|$)');
    return v?v[2]:null
}



$(document).ready(function(){
    $busyindicator.removeChild(spinner.el);
});



$(document).ready(function () {
        $('#reg-type').change(function () {
            if ($('#reg-type').val() == 'CUS') {
                $('#housenum').show();
            }
            else {
                $('#housenum').hide();
            }
        });
    });

$(document).ready(function() {
        $('[data-toggle="tooltip"]').tooltip({'placement': 'top'});
});

$(document).ready (function(){
    $('.up').on('click',function(){
	$('.input-quantity').val(parseInt($('.input-quantity').val())+1);
    });
});

$(document).ready (function(){
    $('.down').on('click',function(){
	if($('.input-quantity').val() == 0) return false; 
	$('.input-quantity').val(parseInt($('.input-quantity').val())-1);
    }); 
});






function countChar(val, maxchars){
var length = val.value.length; 
    if (length >= maxchars){
	val.value = val.value.substring(0, maxchars); 
    }else {
	$('#charcount').text (maxchars - length)
	}
}; 



$formcustsignin.submit ( function() {
    $formcustsignin.hide();
    $.ajax({
	type: "POST",
	url: $formcustsignin.attr("action"),
	data: $formscustignin.serialize(),
	error:function(){
	$error.show();
	},
   	success: function(response){
	    console.log("Customer Signin successful");
	    window.location = "/dodcustindex"; 
	    location.reload(); 

	}
    })
    return false;
    
})

$(document).ready(
    
    function() {
        $( "#required-on" ).datepicker({dateFormat: "dd/mm/yy", minDate: 1} ).attr("readonly", "true");
        }
);



$formvendsignin.submit ( function() {
    $formvendsignin.hide();
    $.ajax({
	type: "POST",
	url: $formsignin.attr("action"),
	data: $formvendsignin.serialize(),
	error:function(){
	$error.show();
	},
   	success: function(response){
	    console.log("Vendor Signin successful");
	    window.location = "/dodvendindex";  
	    location.reload(); 

	}
    })
    return false;
    
})

function displayError(elem, message, timeout) {
     $(elem).show().html('<div class="alert alert-danger alert-dismissible"><button type="button" class="close" data-dismiss="alert" aria-hidden="true"><span aria-hidden="true">&times;</span></button><strong class="text-primary">Warning!&nbsp;&nbsp;</strong><span class="text-primary">'+message+'</span></div>');
    if (timeout || timeout === 0) {
    setTimeout(function() { 
      $(elem).alert('close');
    }, timeout);    
  }
};

function displaySuccess(elem, message, timeout) {
    $(elem).show().html('<div class="alert alert-success alert-dismissible"><button type="button" class="close" data-dismiss="alert" aria-hidden="true"><span aria-hidden="true">&times;</span></button><strong class="text-primary">Success!&nbsp;&nbsp;</strong><span class="text-primary">'+message+'</span></div>');
    if (timeout || timeout === 0) {
    setTimeout(function() { 
      $(elem).alert('close');
    }, timeout);    
  }
};


$(".form-vendordercomplete").on('submit', function (e) {
    var theForm = $(this);
    $(theForm).find("button[type='submit']").hide(); //prop('disabled',true);
      $.ajax({
            type: 'POST',
          url: $(theForm).attr("action"), 
            data: $(theForm).serialize(),
	  error: function (jqXHR, textStatus, errorThrown) {
                  if (jqXHR.status == 500) {
		      displayError("#hhub-error", jqXHR.responseText);
		  }
	      else{
                      alert('Unexpected error.');
                  }},
	  success: function (response) {
		console.log("Completing the Order "); 
		location.reload();
            }
      });
      e.preventDefault();});




$(".form-product").on('submit', function (e) {
    var theForm = $(this);
    $(theForm).find("button[type='submit']").hide(); //prop('disabled',true);
      $.ajax({
            type: 'POST',
          url: $(theForm).attr("action"), 
            data: $(theForm).serialize(),
            success: function (response) {
		console.log("Added a product to cart");
		location.reload();
            }
      });
      e.preventDefault();});

	    
$(".form-shopcart").on('submit', function (e) {
    var theForm = $(this);
    $(theForm).find("button[type='submit']").hide(); //prop('disabled',true);
      $.ajax({
            type: 'POST',
          url: $(theForm).attr("action"), 
            data: $(theForm).serialize(),
            success: function (response) {
		console.log("Updated shopping cart");
		location.reload();

            }
      });
      e.preventDefault();});	
	

function goBack (){
    window.history.back();
}



function CancelConfirm (){
    return confirm("Do you really want to Cancel?");
}

function DeleteConfirm (){
    return confirm("Do you really want to Delete?");
}





$(document).ready(function(){
    $("#livesearch").keyup(function(){
	if (($("#livesearch").val().length ==3) || 
	    ($("#livesearch").val().length == 5)||
	    ($("#livesearch").val().length == 8)||
	    ($("#livesearch").val().length == 13)||
	    ($("#livesearch").val().length == 21)){
	    $.ajax({
		type: "post", 
		cache: false,
		url: $(theForm).attr("action"), 
		data: $(theForm).serialize(),
		success: function(response){
		  
		   //document.getElementById("livesearch").innerHTML=this.responseText;
		//document.getElementById("livesearch").style.border="1px solid #A5ACB2";
			$("#searchresult").html(response); 
		//	$("#finalResult").style.border = "1px solid #a5acb2";
		}, 
		error: function(){      
		    alert('Error while request..');
		}
	    });
	}
	return  false;
    });
});
	


$(document).ready (function(){
    var btn = $('#scrollup');
    
    $(window).scroll(function() {
	if ($(window).scrollTop() > 300) {
	    btn.addClass('show');
	} else {
	    btn.removeClass('show');
	}
    });
    
    btn.on('click', function(e) {
	e.preventDefault();
	$('html, body').animate({scrollTop:0}, '300');
    });
}); 

