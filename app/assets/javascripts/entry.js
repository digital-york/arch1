// DatePickler function
$(function() {
        $('.datePicker').datepicker({
            showOn: "button",
            buttonImage: "/assets/calendar.gif",
            buttonImageOnly: true,
            buttonText: "Select date",
            dateFormat: "dd-mm-yy"
        });
});

// Not being used at present
$(function() {
	$(this).datepicker();
});	


// Display the image zoom popup
function image_zoom_large_popup(page) {
    var popupWidth=1200;
    var popupHeight=800;
    var top = 0;
    var left = (screen.width-popupWidth)/2;
    window.open(page, "myWindow", "status = 1, top = " + top + ", left = " + left + ", height = " + popupHeight + ", width = " + popupWidth + ", scrollbars=yes");
}

// Not being used at present
function validateForm() {
	// <%= form_for @entry, :html=>{:name=>"myForm",:onsubmit=>"return validateForm();"} do |f| %>
	var v = document.getElementsByName("myForm");
	var x = "";
	console.log("start");
	console.log(v);
	for (var i = 0; i < v.length; i++) {
		v2 = v[1];
		for (var j = 0; j < v2.length; j++) {
			var name = v2[j].name;
			var val = v2[j].value;
			if (name == 'entry[entry_no]') {
				if (val == '') {
					console.log('EMPTY!');
					//console.log(v2[j].name);
					//	x = x + v[i].value;
				} else {
					console.log("1" + val + "2");
				}
			}
		}
	}
	console.log("end");
	//event.preventDefault();
	//var s = "false";
	//alert(s);
	return false;
}
