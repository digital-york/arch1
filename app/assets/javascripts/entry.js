
// Datepicker
$(function () {
    $('.datePicker').datepicker({
        showOn: 'button',
        buttonImage: '/assets/calendar.gif',
        buttonImageOnly: true,
        buttonText: 'Select date',
        dateFormat: 'dd-mm-yy'
    });
});

// Not being used at present
$(function () {
    $(this).datepicker();
});

// This code is used if an error occurs and the form is shown again
// Hide any elements which have been removed by the user
// as they will reappear on the page if an error occurs
function hide_elements_when_errors() {
    $('input').each(function (index) {
        if (this.type === 'hidden' && this.value === 'true') {
            var parentTag = $(this).parent().get(0).tagName;
            $(this).parent().parent().css('display', 'none');
        }
    });
}

// Display the image zoom popup
function image_zoom_large_popup(page) {
    var popupWidth = 1200;
    var popupHeight = 800;
    var top = 0;
    var left = (screen.width - popupWidth) / 2;
    window.open(page, 'myWindow', 'status = 1, top = ' + top + ', left = ' + left + ', height = ' + popupHeight + ', width = ' + popupWidth + ', scrollbars=yes');
}


// Methods which add/remove elements to the form
$(document).ready(function () {

    // For multi-value fields - get the 'field_group' div, then append the code template to the end
    $('body').on('click', '.add_field', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var new_code_block = $(this).attr("code_template");
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // Find the 'field_single' div and make 'display' = 'none' in order to hide it, then set the
    // value to '' so that it is deleted by the controller code (see the 'remove_multivalue_blanks' method)
    $('body').on('click', '.remove_field', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_single_div = $(this).parent('div');
            field_single_div.css({'display': 'none'});
            field_single_div.find('input').val('');
        } catch (err) {
            alert(err);
        }
    });

    // This is used for nested elements such as place and person
    // It uses 'field_group' div to find out the appropriate index of the element (i.e how many children exist)
    // It then replaces index and appends the new code block to the end
    $('body').on('click', '.add_field_2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var new_code_block = $(this).attr('code_template');
            var index = field_group_div.children().length;
            new_code_block = new_code_block.replace(/INDEX/g, index);
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });


    // This is used by multi-value fields on nested elements, e.g. 'Place As Written' on the Place element
    // Note that the index is automatically passed by the code template and
    // doesn't have to be replaced in this jquery
    $('body').on('click', '.add_field_3', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var new_code_block = $(this).attr('code_template');
            var parent_div = $(this).parent('th').next('td').find('>:first-child');
            parent_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // This code hides Level 2 elements such as Place
    // Note that a hidden field is also added with '_destroy' = '1' - this
    // is necessary to remove associations in Fedora
    $('body').on('click', '.remove_field_2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_single_div = $(this).parent('div');
            var field_group_div = field_single_div.parent('div');
            field_single_div.css({'display': 'none'});
            // If there is a hidden input element with the 'id', add a '_destroy' = '1' hidden element to make sure
            // that it is deleted from Fedora
            // Note that the uses the Place 'Same As' input field to get the index - maybe there is a better way to do this?
            var input_tag_hidden = field_single_div.find('#hidden_field');
            if (input_tag_hidden.length > 0) {
                var input_tag = field_single_div.find('input');
                var name = input_tag.attr('name');
                var index = get_index(name);
                field_single_div.append("<input type='hidden' name='entry[related_places_attributes][" + index + "][_destroy]' value='1'>");
            }
        } catch (err) {
            alert(err);
        }
    });

    function get_index(attr) {

        try {
            return attr.match(/[0-9]+/);
            ;
        } catch (err) {
            alert(err);
        }

    }

    function increment_index(attr) {

        try {
            var old_index = attr.match(/[0-9]+/);
            var new_index = parseInt(old_index) + 1;
            return new_index;
        } catch (err) {
            alert(err);
        }

    }

    function increment_attribute_index(attr) {

        try {
            var no1 = attr.match(/[0-9]+/);
            var no2 = parseInt(no1) + 1;
            attr = attr.replace(no1, no2);
            return attr;
        } catch (err) {
            alert(err);
        }
    }
});
