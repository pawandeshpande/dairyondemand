
var $busyindicator = document.getElementById('busy-indicator');
var $error = $("#dod-error");
var  $formcustsignin = $(".form-custsignin"),  $formvendsignin = $(".form-vendorsignin");


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


$(document).ready(function () {
    $.ajaxSetup({
    	beforeSend: function(){
           // $('<div class=loadingDiv>loading...</div>').prependTo(document.body);
	    $busyindicator.appendChild(spinner.el);

	},
	complete: function(){
   	    $busyindicator.removeChild(spinner.el);
	}
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



$(".form-vendordercomplete").on('submit', function (e) {
    var theForm = $(this);
    $(theForm).find("button[type='submit']").hide(); //prop('disabled',true);
      $.ajax({
            type: 'POST',
          url: $(theForm).attr("action"), 
            data: $(theForm).serialize(),
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


/*
function showResult(str) {
  if (str.length==0) { 
    document.getElementById("livesearch").innerHTML="";
    document.getElementById("livesearch").style.border="0px";
    return;
  }
  if (window.XMLHttpRequest) {
    // code for IE7+, Firefox, Chrome, Opera, Safari
    xmlhttp=new XMLHttpRequest();
  } else {  // code for IE6, IE5
    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
  xmlhttp.onreadystatechange=function() {
    if (this.readyState==4 && this.status==200) {
      document.getElementById("livesearch").innerHTML=this.responseText;
      document.getElementById("livesearch").style.border="1px solid #A5ACB2";
    }
  }
  xmlhttp.open("GET","livesearchaction.php?q="+str,true);
  xmlhttp.send();
}
*/
