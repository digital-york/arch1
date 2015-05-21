
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

    // Datepicker
    $('.datePicker').datepicker({
            showOn: 'button',
            buttonImage: '/assets/calendar.gif',
            buttonImageOnly: true,
            buttonText: 'Select date',
            dateFormat: 'dd-mm-yy'
    });

    // Not being used at present
    //$(this).datepicker();

    function test() {
        alert("hello world");
    }

    function get_code_template_multiple_select(jq_languages) {

        jq_languages = jq_languages.replace("[[", "[").replace("]]", "]");
        var jq_languages_array = jq_languages.split(",");
        var options = "<option value=''>--- select ---</option>";

        for (i = 0; i < jq_languages_array.length; i++) {
            var value = jq_languages_array[i].replace('[\"', '').replace('\"]', '').trim();
            options = options + "<option value='" + value + "'>" + value + "</option/>";
        }

        return "<div style='padding: 4px 0px' class='field_single'>\
        <select id='entry_language_' name='entry[language][]'>" +
        options +
        "</select>\
        <img alt='Delete icon' src='/assets/delete.png' class='delete_icon remove_field' jq_tag_type='select'>\
        </div>";
    }

    code_template_multiple = "<div style='padding: 4px 0px' class='field_single'>\
        <input type='text' class='input_class' value='' name='entry[jq_type][]'>\
        <img alt='Delete icon' src='/assets/delete.png' class='delete_icon remove_field'>\
        </div>";

// For multi-value fields - get the 'field_group' div, then append the code template to the end
    $('body').on('click', '.add_field', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_type = $(this).attr('jq_type');
            var jq_languages = ''
            if ($(this).attr('jq_languages') != null) {
                jq_languages = $(this).attr('jq_languages');
            }
            var new_code_block = '';
            if (jq_languages != '') {
                new_code_block = get_code_template_multiple_select(jq_languages);
            } else {
                new_code_block = code_template_multiple.replace(/jq_type/, jq_type);
            }
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    code_template_multiple_2 = "<div style='padding: 4px 0px' class='field_single'>\
        <input type='text' class='input_class' value='' name='entry[JS_ATTRIBUTES][JS_INDEX][JS_TYPE][]'>\
        &nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon remove_field'>\
        </div>";

    function get_code_template_place_2(jq_attributes, jq_index, jq_type, jq_label) {
        return "<tr><th style='width: 100px'>" + jq_label +
        "&nbsp;<img jq_type='" + jq_type + "' jq_index='" + jq_index + "' jq_attributes='" + jq_attributes + "' class='plus_icon add_field_3' src='/assets/plus_sign.png'>\
        </th><td><div style='padding: 4px 5px; border: 1px solid silver; min-height: 18px' class='field_group background_gray'></div>\
        </td></tr>";
    }

    function get_code_template_place(jq_index) {
        return "<div class='field_single'>\
         <table class='tab3' cellspacing='0'>"
         + get_code_template_place_2("related_places_attributes", jq_index, "place_as_written", "As Written*")
         + get_code_template_place_2("related_places_attributes", jq_index, "place_type", "Place Type") +
         "<tr><th>Same As*</th><td><input type='text' style='width: 100%' class='input_box' value='' id='' name='entry[related_places_attributes][" + jq_index + "][place_same_as]'></td></tr>"
         + get_code_template_place_2("related_places_attributes", jq_index, "place_note", "Note") +
         "</table>\
         <img src='/assets/delete.png' alt='Delete icon' class='delete_icon remove_field_2' params_type='related_places'>\
         </div>";
    }

    // This is used for nested elements such as place and person
    // It uses 'field_group' div to find out the appropriate index of the element (i.e how many children exist)
    // It then replaces index and appends the new code block to the end
    $('body').on('click', '.add_field_place', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var new_code_block = get_code_template_place(jq_index);
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    function get_code_template_person(jq_index) {
        return "<div class='field_single'>\
         <table class='tab3' cellspacing='0'>"
            + get_code_template_place_2("related_people_attributes", jq_index, "person_as_written", "As Written*") +
            "</table>\
            <img src='/assets/delete.png' alt='Delete icon' class='delete_icon remove_field_2' params_type='related_people'>\
            </div>";
    }

    $('body').on('click', '.add_field_person', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var new_code_block = get_code_template_person(jq_index);
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
            field_single_div.css({'border': '1px solid red'});
            field_single_div.css({'display': 'none'});
            // If the tag type is not null it must be 'select' otherwise it must be 'input'
            // There could be more types later on though
            if ($(this).attr('jq_tag_type') != null) {
                field_single_div.find('select').val('');
            } else {
                field_single_div.find('input').val('');
            }
        } catch (err) {
            alert(err);
        }
    });

    // This is used by multi-value fields on nested elements, e.g. 'Place As Written' on the Place element
    // Note that the index is automatically passed by the code template and
    // doesn't have to be replaced in this code (see add_field_2 above)
    $('body').on('click', '.add_field_3', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_type = $(this).attr('jq_type');
            var new_code_block = code_template_multiple_2;
            new_code_block = new_code_block.replace(/JS_ATTRIBUTES/, jq_attributes);
            new_code_block = new_code_block.replace(/JS_INDEX/, jq_index);
            new_code_block = new_code_block.replace(/JS_TYPE/, jq_type);
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);
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
            // If there is a hidden input element with an 'id', add a '_destroy' = '1' hidden element to make sure
            // that it is deleted from Fedora but don't do it for elements without an 'id' otherwise the elemnt is added to Fedora!
            // Note that the uses the Place 'Same As' input field to get the index - maybe there is a better way to do this?
            var input_tag_hidden = field_single_div.find('#hidden_field');
            if (input_tag_hidden.length > 0) {
                var params_type = $(this).attr('params_type');
                var input_tag = field_single_div.find('input');
                var name = input_tag.attr('name');
                var index = get_index(name);
                field_single_div.append("<input type='hidden' name='entry[" + params_type + "_attributes][" + index + "][_destroy]' value='1'>");
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
