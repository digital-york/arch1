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

// Datepicker method
/*$('.datePicker').datepicker({
 showOn: 'button',
 buttonImage: '/assets/calendar.gif',
 buttonImageOnly: true,
 buttonText: 'Select date',
 dateFormat: 'dd-mm-yy'
 // Not being used at present
 //$(this).datepicker();
 });*/


// Methods which add/remove elements to the form
$(document).ready(function () {

    /*******************************/
    /***** ADD ELEMENT METHODS *****/
    /******************************/

    // Note there are two types of lists which are passed as parameters to the jquery
    // 1 - those which originate from Solr, e.g. role, status, qualification
    // 2 - those which originate from a local file, e.g. language and gender
    // They are handled slightly differently - the Solr are converted to JSON before being passed as a parameter
    // whereas the local lists are already JSON and do not need to be converted
    // e.g. a solr lists could be passed as 'role_list.jo_json' in the HTML code
    // Note also that then the list is passed but used on the 2nd level rather than the first,
    // there appeared to be a problem with spaces and so these were replaced with HTML code &#32;
    // This happened specifically with 'plac e type' but is the probably the same for 'role', etc

    // Click multiple field button (Level 1)
    // e.g. Editorial Note
    $('body').on('click', '.click_multiple_field_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_type = $(this).attr('jq_type');
            var new_code_block = "<div class='field_single'>"
            + "<input type='text' value='' name='entry[" + jq_type + "][]'>"
            + "<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1'>"
            + "</div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    $('body').on('click', '.click_multiple_text_area_field_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_type = $(this).attr('jq_type');
            var new_code_block = "<div class='field_single'>"
            + "<textarea value='' name='entry[" + jq_type + "][]'></textarea>"
            + "<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1'>"
            + "</div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // Click multiple field button (Level 2)
    // e.g. 'As Written' on Person and Place
    $('body').on('click', '.click_multiple_field_button_level2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_type = $(this).attr('jq_type');

            var place_as_written_class = "";
            if (jq_type == 'place_as_written') {
                place_as_written_class = " place_as_written";
            }

            var new_code_block = "<div class='field_single'>"
            + "<input type='text' class='" + place_as_written_class + "' name='entry[" + jq_attributes + "][" + jq_index + "][" + jq_type + "][]'>"
            + "&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1'>"
            + "</div>";
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);

        } catch (err) {
            alert(err);
        }
    });

    // Click select field button (Level 1)
    // e.g. Language (Note: modify the code if other select lists are added here)
    $('body').on('click', '.click_select_field_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_language_list = $.parseJSON($(this).attr('jq_language_list'));

            var language_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_language_list.length; i++) {
                language_options = language_options + "<option value='" + jq_language_list[i].id + "'>" + jq_language_list[i].label + "</option/>";
            }

            var new_code_block = "<div class='field_single'><select id='entry_language_' name='entry[language][]'>" + language_options +
                "</select>&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon_select click_remove_field_level1' jq_tag_type='select'></div>";

            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // Click select field button (Level 2)
    // e.g. Place Type, Role, Qualification
    $('body').on('click', '.click_select_field_button_level2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_type = $(this).attr('jq_type');
            var list_array = "";
            var options = "<option value=''>--- select ---</option>";
            if (jq_type == 'person_role') {
                list_array = $.parseJSON($(this).attr('jq_role_list'));
            } else if (jq_type == 'person_qualification') {
                list_array = $.parseJSON($(this).attr('jq_qualification_list'));
            } else if (jq_type == 'place_type') {
                list_array = $.parseJSON($(this).attr('jq_place_type_list'));
            } else if (jq_type == 'place_role') {
                list_array = $.parseJSON($(this).attr('jq_place_role_list'));
            }
            for (i = 0; i < list_array.length; i++) {
                options = options + "<option value='" + list_array[i].id + "'>" + list_array[i].label + "</option/>";
            }
            var new_code_block = "<div class='field_single'><select name='entry[" + jq_attributes + "][" + jq_index + "][" + jq_type + "][]'>" + options +
                "</select>&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon_select click_remove_field_level1' jq_tag_type='select'></div>";
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    $('body').on('click', '.click_related_place_field_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_type = $(this).attr('jq_type');
            var options = "<option value=''>--- select ---</option>";
            var new_code_block = "<div class='field_single'><select class='related_place' autocomplete='off' name='entry[" + jq_attributes + "][" + jq_index + "][" + jq_type + "][]'>" + options +
                "</select>&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon_select click_remove_field_level1' jq_tag_type='select'></div>";
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);

            // Update the related place list for this element
            // because the user has clicked on the 'plus' button to add a new one
            var options_list = ""
            $(".place_as_written").each(function() {
                options_list += "<option value='" + $(this).val() + "'>" + $(this).val() + "</option>"
            });

            var select_div = $(this).parent('th').next('td').find('select');
            select_div.append(options_list);;
        } catch (err) {
            alert(err);
        }
    });

    // Click place button
    $('body').on('click', '.click_place_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var jq_place_type_list = $(this).attr('jq_place_type_list').replace(/ /g, "&#32;"); // Appears to be a problem when list is added as a nested list, i.e. Level 2, therefore replace them here
            var jq_place_role_list = $(this).attr('jq_place_role_list').replace(/ /g, "&#32;"); // See above

            var new_code_block = "<div class='field_single'>" +

                "<table class='tab3' cellspacing='0'>" +

                // Place Role
                "<tr><th>Place Role&nbsp;<img jq_place_role_list=" + jq_place_role_list +
                " jq_type='" + "place_role" + "' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                // As Written
                "<tr><th style='width: 110px'>As Written*" +
                "&nbsp;<img jq_type='place_as_written' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_multiple_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                // Place Type
                "<tr><th>Place Type&nbsp;<img jq_place_type_list=" + jq_place_type_list +
                " jq_type='" + "place_type" + "' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                // Same As
                "<tr><th>Same As*</th><td class='input_single'><input type='text' value='' id='' name='entry[related_places_attributes][" + jq_index + "][place_same_as]'></td></tr>" +

                // Note
                "<tr><th>Note" +
                "&nbsp;<img jq_type='place_note' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_multiple_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                "</table>" +
                "<img src='/assets/delete.png' alt='Delete icon' class='delete_icon click_remove_field_level2' params_type='related_places'>" +
                "</div>";

            field_group_div.append(new_code_block);

        } catch (err) {
            alert(err);
        }
    });

    // Click person button
    $('body').on('click', '.click_person_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var jq_role_list = $(this).attr('jq_role_list').replace(/ /g, "&#32;"); //  // Appears to be a problem when list is added as a nested list, i.e. Level 2, therefore replace them here
            var jq_qualification_list = $(this).attr('jq_qualification_list').replace(/ /g, "&#32;"); // See note on line above
            var jq_status_list = $.parseJSON($(this).attr('jq_status_list')); // Don't need to remove spaces because not nested like the above lists (I think)
            var jq_gender_list = $.parseJSON($(this).attr('jq_gender_list'));

            var status_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_status_list.length; i++) {
                status_options = status_options + "<option value='" + jq_status_list[i].id + "'>" + jq_status_list[i].label + "</option/>";
            }

            var gender_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_gender_list.length; i++) {
                gender_options = gender_options + "<option value='" + jq_gender_list[i] + "'>" + jq_gender_list[i] + "</option/>";
            }

            var new_code_block = "<div class='field_single'>" +

                "<table class='tab3' cellspacing='0'>" +

                    // As Written
                "<tr><th style='width: 110px'>As Written*" +
                "&nbsp;<img jq_type='person_as_written' jq_index='" + jq_index + "' jq_attributes='related_people_attributes' class='plus_icon click_multiple_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                    // Role
                "<tr><th style='width: 110px'>Role" +
                "&nbsp;<img jq_role_list=" + jq_role_list + " jq_type='" + "person_role" + "' jq_index='" + jq_index + "' jq_attributes='related_people_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                    // Qualification
                "<tr><th style='width: 110px'>Qualification" +
                "&nbsp;<img jq_qualification_list=" + jq_qualification_list + " jq_type='person_qualification' jq_index='" + jq_index + "' jq_attributes='related_people_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                    // Status
                "<tr><th>Status</th><td><select name='entry[related_people_attributes][" + jq_index + "][person_status]'>" + status_options + "</select></td></tr>" +

                    // Gender
                "<tr><th>Gender</th><td><select name='entry[related_people_attributes][" + jq_index + "][person_gender]'>" + gender_options + "</select></td></tr>" +

                    // Same As
                "<tr><th>Same As*</th><td class='input_single'><input type='text' value='' id='' name='entry[related_people_attributes][" + jq_index + "][person_same_as]'></td></tr>" +

                    // Related Place
                "<tr><th>Related Place" +
                "&nbsp;<img jq_type='person_related_place' jq_index='" + jq_index + "' jq_attributes='related_people_attributes' class='plus_icon click_related_place_field_button' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                    // Note
                "<tr><th>Note*" +
                "&nbsp;<img jq_type='person_note' jq_index='" + jq_index + "' jq_attributes='related_people_attributes' class='plus_icon click_multiple_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group gray_box'></div></td></tr>" +

                "</table>" +
                "<img src='/assets/delete.png' alt='Delete icon' class='delete_icon click_remove_field_level2' params_type='related_people'>" +
                "</div>";

            field_group_div.append(new_code_block);

        } catch (err) {
            alert(err);
        }
    });

    // Click date button
    $('body').on('click', '.click_date_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index = field_group_div.children().length;
            var jq_date_type_list = $.parseJSON($(this).attr('jq_date_type_list')); // // Don't need to remove spaces because not nested like the two lists below (I think)
            var jq_date_role_list = $.parseJSON($(this).attr('jq_date_role_list')) // See note on line above
            var jq_date_certainty_list = $(this).attr('jq_date_certainty_list').replace(/ /g, "&#32;");  // Appears to be a problem when list is added as a nested list, i.e. Level 2, therefore replace them here
            var jq_single_date_list = $(this).attr('jq_single_date_list').replace(/ /g, "&#32;"); // See note on line above

            var date_type_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_date_type_list.length; i++) {
                date_type_options = date_type_options + "<option value='" + jq_date_type_list[i].id + "'>" + jq_date_type_list[i].label + "</option/>";
            }

            var date_role_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_date_role_list.length; i++) {
                date_role_options = date_role_options + "<option value='" + jq_date_role_list[i].id + "'>" + jq_date_role_list[i].label + "</option/>";
            }

            var new_code_block = "<div class='field_single no_padding'>" +

                "<table class='tab3' cellspacing='0'>" +

                // As Written
                "<tr><th style='width: 110px'>As Written</th><td class='input_single'><input type='text' value='' id='' name='entry[entry_dates_attributes][" + jq_index + "][date_as_written]'></td></tr>" +

                // Note
                "<tr><th>Note</th><td class='input_single'><input type='text' value='' id='' name='entry[entry_dates_attributes][" + jq_index + "][date_note]'></td></tr>" +

                // Date Role
                "<tr><th>Date Role</th><td><select name='entry[entry_dates_attributes][" + jq_index + "][date_role]'>" + date_role_options + "</select></td></tr>" +

                // Date Type
                "<tr><th>Date Type</th><td><select name='entry[entry_dates_attributes][" + jq_index + "][date_type]'>" + date_type_options + "</select></td></tr>" +

                // Date
                "<tr><th>Date&nbsp;<img jq_date_certainty_list='" + jq_date_certainty_list + "' jq_single_date_list='" + jq_single_date_list + "' jq_index='" + jq_index + "' class='plus_icon click_single_date_button' src='/assets/plus_sign.png'></th><td><div class='field_group gray_box single_date'></div></td></tr>" +

                "</table>" +
                "<img src='/assets/delete.png' alt='Delete icon' class='delete_icon click_remove_field_level2' params_type='related_places'>" +
                "</div>";

            field_group_div.append(new_code_block);

        } catch (err) {
            alert(err);
        }
    });

    // Click single date button
    $('body').on('click', '.click_single_date_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_index = $(this).attr('jq_index');
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_index2 = field_group_div.children().length;
            var jq_date_certainty_list = $.parseJSON($(this).attr('jq_date_certainty_list')); //.replace(/ /g, "&#32;"); // Doesn't like spaces but quotes are OK?!
            var jq_single_date_list = $.parseJSON($(this).attr('jq_single_date_list')); //.replace(/ /g, "&#32;"); // Doesn't like spaces but quotes are OK?!

            var date_certainty_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_date_certainty_list.length; i++) {
                date_certainty_options = date_certainty_options + "<option value='" + jq_date_certainty_list[i].id + "'>" + jq_date_certainty_list[i].label + "</option/>";
            }

            var single_date_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_single_date_list.length; i++) {
                single_date_options = single_date_options + "<option value='" + jq_single_date_list[i].id + "'>" + jq_single_date_list[i].label + "</option/>";
            }

            var new_code_block = "<div class='field_single'>" +

                "<table>" +

                    // Date Certainty
                "<tr><th style='width: 60px'>Certainty:</th>" +
                "<td><select name='entry[entry_dates_attributes][" + jq_index + "][single_dates_attributes][" + jq_index2 + "][date_certainty]'>" + date_certainty_options + "</select></td>" +

                    // Date
                "<tr><th>Date:</th>" +
                "<td class='input_single'><input id='' type='text' name='entry[entry_dates_attributes][" + jq_index + "][single_dates_attributes][" + jq_index2 + "][date]'></td>" +

                    // Type
                "<tr><th>Type:</th>" +
                "<td><select name='entry[entry_dates_attributes][" + jq_index + "][single_dates_attributes][" + jq_index2 + "][date_type]'>" + single_date_options + "</select></td>" +

                "</table>" +
                "<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_date' jq_index1='" + jq_index2 + "'>" +
                "<div style='clear: both'></div></div>";

            $(this).parent('th').next('td').find('.field_group').append(new_code_block);

        } catch (err) {
            alert(err);
        }
    });


    /**********************************/
    /***** REMOVE ELEMENT METHODS *****/
    /**********************************/

    // Find the 'field_single' div and make 'display' = 'none' in order to hide it, then set the
    // value to '' so that it is deleted by the controller code (see the 'remove_multivalue_blanks' method)
    $('body').on('click', '.click_remove_field_level1', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_single_div = $(this).parent('div');
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
    $('body').on('click', '.click_remove_field_level2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_single_div = $(this).parent('div');
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

    // Remove date
    $('body').on('click', '.click_remove_field_date', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_single_div = $(this).parent('div');
            //var field_group_div = field_single_div.parent('div');
            var jq_index1 = $(this).attr('jq_index1');
            field_single_div.css({'display': 'none'});
            // If there is a hidden input element with an 'id', add a '_destroy' = '1' hidden element to make sure
            // that it is deleted from Fedora but don't do it for elements without an 'id' otherwise the element is added to Fedora!
            // Note that the uses the Place 'Same As' input field to get the index - maybe there is a better way to do this?
            var input_tag_hidden = field_single_div.find('#hidden_field');
            if (input_tag_hidden.length > 0) { // i.e. if there is a hidden field, it must be an 'id'
                var params_type = $(this).attr('params_type');
                var input_tag = field_single_div.find('input');
                var name = input_tag.attr('name');
                name = name.substring(name.indexOf('single_dates_attributes')); // This removes the first index from the 'name' as we want the seond number
                var jq_index2 = get_index(name);
                field_single_div.append("<input type='hidden' name='entry[entry_dates_attributes][" + jq_index1 + "][single_dates_attributes][" + jq_index2 + "][_destroy]' value='1'>");
            }
        } catch (err) {
            alert(err);
        }
    });

    function get_index(attr) {

        try {
            return attr.match(/[0-9]+/);
        } catch (err) {
            alert(err);
        }
    }

    function get_last_index(attr) {

        try {
            return attr.match(/[0-9]+/);
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

    // Calls the function below when a place_as_written is changed (or added)
    $('body').on('change', '.place_as_written', function(e) {

        update_related_places();

    });

});

// This is called if the user changes a place_as_written - it updates all the related place lists
function update_related_places() {

    console.log('start');

    var options_list = "<option value=''>--- select ---</option>"

    // Need to change this so that the elements are only removed if they no longer exist
    // and new ones are added

    $('.place_as_written').each(function() {

        options_list += "<option value='" + $(this).val() + "'>" + $(this).val() + "</option>"

        //$(this).css("border", "3px solid green")

        var place_as_written_value = $(this).val();

        $('.related_place').each(function() {

            //$(this).css("border", "3px solid green");

            $(this).find('option').each(function() {

                var related_place_value = $(this).val()
                //console.log($(this).val());

                if (place_as_written_value != related_place_value) {
                    console.log(place_as_written_value);
                }
            });
        });
    });

    console.log('end');

    //$('.related_place').find('option').remove();
    //$('.related_place').append(options_list);
}
