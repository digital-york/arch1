// datepicker
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

// Hide any elements which have been removed by the user
// as they will reappear on the page if an error occurs
function hide_elements_when_errors() {
    console.log("start");
    $("input").each(function(index) {
        console.log(index);
        if (this.type === "hidden" && this.value === "true") {
            var parentTag = $(this).parent().get(0).tagName;
            $(this).parent().parent().css("display", "none");
            //console.log("MATCH: id=" + this.id + ": name=" + this.name + ": value=" + this.value + ": type=" + this.type + ": parent=" + parentTag);
        }
    });
    console.log("end");
}

// Display the image zoom popup
function image_zoom_large_popup(page) {
    var popupWidth=1200;
    var popupHeight=800;
    var top = 0;
    var left = (screen.width-popupWidth)/2;
    window.open(page, "myWindow", "status = 1, top = " + top + ", left = " + left + ", height = " + popupHeight + ", width = " + popupWidth + ", scrollbars=yes");
}
