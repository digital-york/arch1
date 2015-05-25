
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

    // Datepicker method
    $('.datePicker').datepicker({
            showOn: 'button',
            buttonImage: '/assets/calendar.gif',
            buttonImageOnly: true,
            buttonText: 'Select date',
            dateFormat: 'dd-mm-yy'
        // Not being used at present
        //$(this).datepicker();
    });

    var jq_language_array = ["english", "latin", "french", "german", "undefined"];
    var jq_role_array = ["role 1", "role 2", "role 3"];
    var jq_qualification_array = ["qualification 1", "qualification 2", "qualification 3"];
    var jq_date_type_array = ["recited date", "court date"];

    /*******************************/
    /***** ADD ELEMENT METHODS *****/
    /******************************/

    // ADD FIELD LEVEL1 (MULTIPLE)
    $('body').on('click', '.add_field_level1_multiple', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_type = $(this).attr('jq_type');
            var new_code_block = "<div style='padding: 4px 0px' class='field_single'>\
            <input type='text' class='input_class' value='' name='entry[" + jq_type + "][]'>\
            <img alt='Delete icon' src='/assets/delete.png' class='delete_icon remove_field_level1'>\
            </div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // ADD FIELD LEVEL1 (SELECT)
    $('body').on('click', '.add_field_level1_select', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var options = "<option value=''>--- select ---</option>";
            var list_array = jq_language_array;
            for (i = 0; i < list_array.length; i++) {
                var options = options + "<option value='" + list_array[i] + "'>" + list_array[i] + "</option/>";
            }
            var new_code_block = "<div style='padding: 4px 0px' class='field_single'><select id='entry_language_' name='entry[language][]'>" + options +
                "</select>&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon_select remove_field_level1' jq_tag_type='select'></div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // ADD FIELD LEVEL1 (PLACE)
    $('body').on('click', '.add_field_level1_place', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var new_code_block = "<div class='field_single'>\
                <table class='tab3' cellspacing='0'>"
                + get_template_level1_level2_multiple("related_places_attributes", jq_index, "place_as_written", "As Written*")
                + get_template_level1_level2_multiple("related_places_attributes", jq_index, "place_type", "Place Type") +
                "<tr><th>Same As*</th><td><input type='text' style='width: 100%' class='input_box' value='' id='' name='entry[related_places_attributes][" + jq_index + "][place_same_as]'></td></tr>"
                + get_template_level1_level2_multiple("related_places_attributes", jq_index, "place_note", "Note") +
                "</table>\
                <img src='/assets/delete.png' alt='Delete icon' class='delete_icon remove_field_level2' params_type='related_places'>\
                </div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // ADD FIELD LEVEL1 / LEVEL2 MULTIPLE
    // Used in Person / Place
    //function get_template_level1_level2_multiple(jq_attributes, jq_index, jq_type, jq_label) {
    //    return "<tr><th style='width: 100px'>" + jq_label +
    //        "&nbsp;<img jq_type='" + jq_type + "' jq_index='" + jq_index + "' jq_attributes='" + jq_attributes + "' class='plus_icon add_field_level2_multiple' src='/assets/plus_sign.png'>\
    //    </th><td><div style='padding: 4px 5px; border: 1px solid silver; min-height: 18px' class='field_group background_gray'></div>\
    //    </td></tr>";
    //}

    // ADD FIELD LEVEL2 (MULTIPLE)
    $('body').on('click', '.add_field_level2_multiple', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_type = $(this).attr('jq_type');
            var new_code_block = "<div style='padding: 4px 0px' class='field_single'>\
            <input type='text' class='input_class' name='entry[" + jq_attributes + "][" + jq_index + "][" + jq_type + "][]'>\
            &nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon remove_field_level1'>\
            </div>";
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // ADD FIELD LEVEL1 (PERSON)
    $('body').on('click', '.add_field_level1_person', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var new_code_block = "<div class='field_single'>\
                <table class='tab3' cellspacing='0'>"
                + get_template_level1_level2_multiple("related_people_attributes", jq_index, "person_as_written", "As Written*")
                + get_template_level1_level2_select("related_people_attributes", jq_index, "person_role", "Role")
                + get_template_level1_level2_select("related_people_attributes", jq_index, "person_qualification", "Qualification") +
                "<tr><th>Gender</th><td><select name='entry[related_people_attributes][" + jq_index + "][person_gender]'><option>--- select ---</option><option>Male</option><option>Female</option><option>Undefined</option></select></td></tr>" +
                "<tr><th>Same As*</th><td><input type='text' style='width: 100%' class='input_box' value='' id='' name='entry[related_people_attributes][" + jq_index + "][person_same_as]'></td></tr>" +
                + get_template_level1_level2_multiple("related_people_attributes", jq_index, "person_related_place", "Related Place")
                + get_template_level1_level2_multiple("related_people_attributes", jq_index, "person_place_of_residence", "Residence")
                + get_template_level1_level2_multiple("related_people_attributes", jq_index, "person_note", "Note") +
                "</table>\
                <img src='/assets/delete.png' alt='Delete icon' class='delete_icon remove_field_level2' params_type='related_people'>\
                </div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // ADD FIELD LEVEL1 / LEVEL2 MULTIPLE
    // Used in Person / Place
    function get_template_level1_level2_multiple(jq_attributes, jq_index, jq_type, jq_label) {
        return "<tr><th style='width: 100px'>" + jq_label +
            "&nbsp;<img jq_type='" + jq_type + "' jq_index='" + jq_index + "' jq_attributes='" + jq_attributes + "' class='plus_icon add_field_level2_multiple' src='/assets/plus_sign.png'>\
        </th><td><div style='padding: 4px 5px; border: 1px solid silver; min-height: 18px' class='field_group background_gray'></div>\
        </td></tr>";
    }

    // ADD FIELD LEVEL1 / LEVEL2 SELECT
    // Used in Person
    function get_template_level1_level2_select(jq_attributes, jq_index, jq_type, jq_label) {
        return "<tr><th style='width: 100px'>" + jq_label +
            "&nbsp;<img jq_type='" + jq_type + "' jq_index='" + jq_index + "' jq_attributes='" + jq_attributes + "' class='plus_icon add_field_level2_select' src='/assets/plus_sign.png'>\
        </th><td><div style='padding: 4px 5px; border: 1px solid silver; min-height: 18px' class='field_group background_gray'></div>\
        </td></tr>";
    }

    // ADD FIELD LEVEL1 (DATE)
    $('body').on('click', '.add_field_level1_date', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var options = "<option value=''>--- select ---</option>";
            for (i = 0; i < jq_date_type_array.length; i++) {
                options = options + "<option value='" + jq_date_type_array[i] + "'>" + jq_date_type_array[i] + "</option/>";
            }
            var new_code_block = "<div class='field_single'>\
                <table class='tab3' cellspacing='0'>" +
                "<tr><th>As Written</th><td><input type='text' style='width: 100%' class='input_box' value='' id='' name='entry[entry_dates_attributes][" + jq_index + "][date_as_written]'></td></tr>" +
                "<tr><th>Note</th><td><input type='text' style='width: 100%' class='input_box' value='' id='' name='entry[entry_dates_attributes][" + jq_index + "][date_note]'></td></tr>" +
                "<tr><th>Date Type</th><td><select name='entry[entry_dates_attributes][" + jq_index + "][date_type]'>" + options + "</select></td></tr>" +
                "</table>\
                <img src='/assets/delete.png' alt='Delete icon' class='delete_icon remove_field_level2' params_type='related_places'>\
                </div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // ADD FIELD LEVEL2 (SELECT)
    $('body').on('click', '.add_field_level2_select', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_type = $(this).attr('jq_type');
            var options = "<option value=''>--- select ---</option>";
            var list_array = "";
            if (jq_type == 'person_role') {
                list_array = jq_role_array;
            } else {
                list_array = jq_qualification_array;
            }
            for (i = 0; i < list_array.length; i++) {
                options = options + "<option value='" + list_array[i] + "'>" + list_array[i] + "</option/>";
            }
            var new_code_block = "<div style='padding: 4px 0px' class='field_single'><select name='entry[" + jq_attributes + "][" + jq_index + "][" + jq_type + "][]'>" + options +
                "</select>&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon_select remove_field_level1' jq_tag_type='select'></div>";
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    /*******************************/
    /***** REMOVE ELEMENT METHODS *****/
    /******************************/

    // Find the 'field_single' div and make 'display' = 'none' in order to hide it, then set the
    // value to '' so that it is deleted by the controller code (see the 'remove_multivalue_blanks' method)
    $('body').on('click', '.remove_field_level1', function (e) {

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

    // This code hides Level 2 elements such as Place
    // Note that a hidden field is also added with '_destroy' = '1' - this
    // is necessary to remove associations in Fedora
    $('body').on('click', '.remove_field_level2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_single_div = $(this).parent('div');
            var field_group_div = field_single_div.parent('div');
            field_single_div.css({'display': 'none'});
            // If there is a hidden input element with an 'id', add a '_destroy' = '1' hidden element to make sure
            // that it is deleted from Fedora but don't do it for elements without an 'id' otherwise the element is added to Fedora!
            // Note that the uses the Place 'Same As' input field to get the index - maybe there is a better way to do this?
            var input_tag_hidden = field_single_div.find('#hidden_field');
            if (input_tag_hidden.length > 0) { // i.e. if there is a hidden field, it must be an 'id'
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
