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

// Used to post value back to calling page, i.e. in subject, person and place popups
function post_value(value, id, field) {
    opener.document.getElementById(field).innerHTML = value;
    opener.document.getElementById(field + "_hidden").value = id;
    self.close();
}

function remove_authority(type, index) {
    document.getElementById(type + "_" + index).innerHTML = '';
    document.getElementById(type + "_" + index + "_hidden").value = '';
}

function reset_box(id) {
  document.getElementById('search_box').value = '';
}

function popup(page, type) {

    var popup_id = Math.floor(Math.random() * 100000) + 1;

    var popupWidth = 0;
    var popupHeight = 0;
    var top = 0;
    var left = 0;

    if (type == "image_zoom_large") {
        popupWidth = 1200;
        popupHeight = 800;
        left = (screen.width - popupWidth) / 2;
    } else if (type == "subject") {
        popupWidth = 1000;
        popupHeight = screen.height / 1.25;
        left = (screen.width - popupWidth) / 2;
        popup_id = "101"
    } else if (type == "person") {
        popupWidth = 1000;
        popupHeight = screen.height / 1.25;
        left = (screen.width - popupWidth) / 2;
        popup_id = "102"
    } else if (type == "place") {
        popupWidth = 1000;
        popupHeight = screen.height / 1.25;
        left = (screen.width - popupWidth) / 2;
        popup_id = "103"
    } else if (type == "admin") {
        popupWidth = 1000;
        popupHeight = screen.height / 1.25;
        left = (screen.width - popupWidth) / 2;
        top = 50;
        popup_id = "104"
    } else if (type == "browse_folios") {
        popupWidth = 522;
        popupHeight = 605;
        left = (screen.width - popupWidth) / 2;
    }

    window.open(page, type + "_" + popup_id, 'status = 1, location = 1, top = ' + top + ', left = ' + left + ', height = ' + popupHeight + ', width = ' + popupWidth + ', scrollbars=yes');
}

var dummy_text = "\
<p class='help_text_header'>Entry:</p>\
<p><strong>Entry Number</strong>: automatically generated sequence number for entries on a particular folio</p>\
<p><strong>Entry Type</strong>: general classification for the type of entry, choose from the drop-down list</p>\
<p><strong>Continues on next folio</strong>: indicates whether this entry continues on the next folio (add when you press the button</p>\
<p><strong>Summary</strong>: very brief text summary of the contents of the Entry</p>\
<p><strong>Marginalia</strong>: marginal notes</p>\
<p><strong>Language</strong>: language of the entry, choose from the drop-down list</p>\
<p><strong>Subject</strong>: choose one or more subject headings from the pop-up</p>\
<p><strong>Note</strong>: any general notes about the entry that do not fit elsewhere, intended for public users</p>\
<p><strong>Editorial notes</strong>: notes about the editing process, eg. areas that were difficult to read, not intended for public users</p>\
<p><strong>Referenced By</strong>: bibliographic reference for the entry in printed editions or citations in other works</p>\
<p class='help_text_header'>Date: dates referenced in the entry</p>\
<p><strong>Date</strong>: an individual date; for date ranges add two dates, one with type=start and one with type=end</p>\
<p><strong>Date Role</strong>: the role of the date in the document, choose from the drop-down list</p>\
<p><strong>Note</strong>: general notes about the date</p>\
<p class='help_text_header'>Place: places referenced in the entry</p>\
<p><strong>As Written</strong>: transcribe the place as written</p>\
<p><strong>Place Name Authority</strong>: this field has not yet been implemented, please ignore</p>\
<p><strong>Place Role</strong>: the role of the place in the document, choose from the drop-down list</p>\
<p><strong>Place Type</strong>: the type of place, choose from the drop-down list</p>\
<p><strong>Note</strong>: general notes about the place</p>\
<p class='help_text_header'>Person: persons referenced in the entry</p>\
<p><strong>As Written</strong>: transcribe the person’s name as written</p>\
<p><strong>Person Name Authority</strong>: this field has not yet been implemented, please ignore</p>\
<p><strong>Gender</strong>: choose from the drop-down list</p>\
<p><strong>Person Role</strong>: the role of the person in the document, choose from the drop-down list</p>\
<p><strong>Descriptor</strong>: the status, qualification or occupation of the person, choose from the drop-down list</p>\
<p><strong>Note</strong>: general notes about the person</p>\
<p><strong>Related Place</strong>: if a place entered above is related to this person rather than the entry as a whole, link them here</p>";

// Shows the info pop-up when a question mark is clicked
function info(title) {
    var text = "..."
    var string = "<html><head><style>li { padding: 5px; } .help_text_header { font-size: 1.3em; font-weight: bold; }</style><title>" + title + "</title><body style='font-family: Arial,Helvetica,sans-serif; font-size: 80%;'>";
    string += "<h2>" + title + "</h2> ";
    string += "<p style='text-align: justify'>" + dummy_text + "</p>";
    string += "<br/><br/><a href='javascript:window.close()' style='color: #A14685; font-size: 0.9em; font-weight: bold; text-decoration: none;'>" + "CLOSE" + "</a>";
    string += "</body></html>";
    var popupWidth = 700;
    var popupHeight = 500;
    var left = (screen.width - popupWidth) / 2;
    var top = (screen.height - popupHeight) / 4;
    helpWindow = window.open('', 'id1', 'scrollbars=yes, left=' + left + ', top=' + top + ', width=' + popupWidth + ', height=' + popupHeight);
    helpWindow.document.open("text/html");
    helpWindow.document.write(string);
    helpWindow.document.close();
}

// Methods which add/remove elements to the form
$(document).ready(function () {

    // Not used any more - keep here just in case they're needed again
    // Open subject popup group
    /*$('body').on('click', '.plus_icon_subject', function(e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            $(this).attr("src", "/assets/minus_icon_subject.png");
            $(this).removeClass('plus_icon_subject');
            $(this).addClass('minus_icon_subject');
            var div_tag = $(this).next();
            div_tag.show();

        } catch (err) {
            alert(err);
        }
    });

    // Close subject popup group
    $('body').on('click', '.minus_icon_subject', function(e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            $(this).attr("src", "/assets/plus_icon_subject.png");
            $(this).removeClass('minus_icon_subject');
            $(this).addClass('plus_icon_subject');
            var div_tag = $(this).next();
            div_tag.hide();

        } catch (err) {
            alert(err);
        }
    });*/

    // Called when the user chooses a folio from the menu drop-down list
    $('body').on('change', '.choose_folio', function(e) {
        var id = $(this).val();
        var input = $("<input>").attr("type", "hidden").attr("name", "folio_id").val(id);
        $("#choose_folio").append($(input));
        $("#choose_folio").submit();
    });

    /*******************************/
    /***** ADD ELEMENT METHODS *****/
    /******************************/

    // Note there are two types of lists which are passed as parameters to the jquery
    // 1 - those which originate from Solr, e.g. role, descriptor
    // 2 - those which originate from a local file, e.g. language and gender
    // They are handled slightly differently - the Solr are converted to JSON before being passed as a parameter
    // whereas the local lists are already JSON and do not need to be converted
    // e.g. a solr lists could be passed as 'role_list.jo_json' in the HTML code
    // Note also that then the list is passed but used on the 2nd level rather than the first,
    // there appeared to be a problem with spaces and so these were replaced with HTML code &#32;
    // This happened specifically with 'place type' but is the probably the same for 'role', etc

    // Click multiple field button (Level 1)
    // e.g. Editorial Note
    $('body').on('click', '.click_multiple_field_button', function (e) {
        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            var jq_type = $(this).attr('jq_type');
            var new_code_block = "<div class='field_single'>"
                + "<input type='text' value='' name='entry[" + jq_type + "][]'>"
                + "<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1' jq_tag_type='input'>"
                + "</div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // Click multiple field subject button (Level 1)
    $('body').on('click', '.click_multiple_subject_field_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            //field_group_div.css("border", "1px solid red");
            var no_elements = field_group_div.children('.field_single').length;
            var jq_type = $(this).attr('jq_type');
            var new_code_block = "<div class='field_single'>"
                + "<a href='#' onclick='popup(&#39;/subjects?subject_field=subject_" + no_elements + "&#39;, &#39;subject&#39;); return false;' tabindex='-1'><img src='/assets/magnifying_glass_small.png' class='plus_icon'></a>"
                + "&nbsp;<span id='subject_" + no_elements + "'></span>"
                + "<input id='subject_" + no_elements + "_hidden' type='hidden' value='' name='entry[" + jq_type + "][]'>"
                + "<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1' jq_tag_type='input'>"
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
                + "<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1' jq_tag_type='textarea'>"
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
            // NOTE: 'place_as_written' is required for 'related places' to work - see the 'update_related_places' method below
            var input_class = "";
            if (jq_type == "place_as_written") {
                input_class="class='place_as_written' ";
            }
            var new_code_block = "<div class='field_single'>"
                + "<input type='text'" + input_class + "name='entry[" + jq_attributes + "][" + jq_index + "][" + jq_type + "][]'>"
                + "&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1' jq_tag_type='input'>"
                + "</div>";
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);

        } catch (err) {
            alert(err);
        }
    });

    // Click multiple text area button (Level 2)
    // e.g. 'Note' on Person and Place
    $('body').on('click', '.click_multiple_text_area_button_level2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_type = $(this).attr('jq_type');

            var new_code_block = "<div class='field_single'>"
                + "<textarea name='entry[" + jq_attributes + "][" + jq_index + "][" + jq_type + "][]'/>"
                + "&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1' jq_tag_type='textarea'>"
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
            var jq_type = $(this).attr('jq_type');
            var list_array = "";
            if (jq_type == 'language') {
                list_array = $.parseJSON($(this).attr('jq_language_list'));
            } else if (jq_type == 'entry_type') {
                list_array = $.parseJSON($(this).attr('jq_entry_type_list'));
            } else if (jq_type == 'section_type') {
                list_array = $.parseJSON($(this).attr('jq_section_type_list'));
            }

            var options = "<option value=''>--- select ---</option>";

            for (i = 0; i < list_array.length; i++) {
                options = options + "<option value='" + list_array[i].id + "'>" + list_array[i].label + "</option/>";
            }

            var new_code_block = "<div class='field_single'><select name='entry[" + jq_type + "][]'>" + options +
                "</select>&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon_select click_remove_field_level1' jq_tag_type='select'></div>";
            $(this).parent('th').next('td').find('.field_group').append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // Click select field button (Level 2)
    // e.g. Place Type, Role
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
            } else if (jq_type == 'place_type') {
                list_array = $.parseJSON($(this).attr('jq_place_type_list'));
            } else if (jq_type == 'place_role') {
                list_array = $.parseJSON($(this).attr('jq_place_role_list'));
            } else if (jq_type == 'person_descriptor') {
                list_array = $.parseJSON($(this).attr('jq_descriptor_list'));
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

            // Need to do this otherwise 'Related Place' will not have any options
            update_related_places();

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
            var jq_rdftype = $(this).attr('jq_rdftype')

            var new_code_block = "<div class='field_single'>" +

                "<table class='tab3' cellspacing='0'>" +

                // As Written
                // NOTE: 'place_as_written_block' is required for 'related places' to work - see the 'update_related_places' method below
                "<tr><th>*As Written:" +
                "&nbsp;<img jq_type='place_as_written' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_multiple_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box place_as_written_block'></div></td></tr>" +

                // Place Name Authority (Same As)
                "<tr><th>Place Name Authority:</th><td class='input_single'>" +
                "<a href='' onclick='popup(&#39;/places?start=true&amp;place_field=place_" + jq_index + "&#39;, &#39;place&#39;); return false;' tabindex='-1'><img src='/assets/magnifying_glass_small.png' class='plus_icon'></a>" +
                "&nbsp;<span id='place_" + jq_index + "'></span>" +
                "<input type='hidden' id='place_" + jq_index + "_hidden' value='' name='entry[related_places_attributes][" + jq_index + "][place_same_as]'>" +
                "</td></tr>" +

                // Place Role
                "<tr><th>Place Role:&nbsp;<img jq_place_role_list=" + jq_place_role_list +
                " jq_type='" + "place_role" + "' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Place Type
                "<tr><th>Place Type:&nbsp;<img jq_place_type_list=" + jq_place_type_list +
                " jq_type='" + "place_type" + "' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Note
                "<tr><th>Note:" +
                "&nbsp;<img jq_type='place_note' jq_index='" + jq_index + "' jq_attributes='related_places_attributes' class='plus_icon click_multiple_text_area_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Hidden field for RDFTYPE
                "<tr><input type='hidden' id='hidden_field' name='entry[related_places_attributes][" + jq_index + "][rdftype]' value='" + jq_rdftype + "'></tr>" +


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
            var jq_descriptor_list = $(this).attr('jq_descriptor_list').replace(/ /g, "&#32;"); // See above
            var jq_gender_list = $.parseJSON($(this).attr('jq_gender_list')); // Don't need to remove spaces because not nested like the above lists (I think)
            var jq_rdftype = $(this).attr('jq_rdftype')

            var descriptor_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_descriptor_list.length; i++) {
                descriptor_options = descriptor_options + "<option value='" + jq_descriptor_list[i].id + "'>" + jq_descriptor_list[i].label + "</option/>";
            }

            var gender_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_gender_list.length; i++) {
                gender_options = gender_options + "<option value='" + jq_gender_list[i] + "'>" + jq_gender_list[i] + "</option/>";
            }

            var new_code_block = "<div class='field_single'>" +

                "<table class='tab3' cellspacing='0'>" +

                 // As Written
                "<tr><th style='width: 110px'>*As Written:" +
                "&nbsp;<img jq_type='person_as_written' jq_index='" + jq_index + "' jq_attributes='related_person_groups_attributes' class='plus_icon click_multiple_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Person Name Authority (Same As)
                "<tr><th>Person Name Authority:</th><td class='input_single'>" +
                "<a href='' onclick='popup(&#39;/people?start=true&amp;person_field=person_" + jq_index + "&#39;, &#39;person&#39;); return false;' tabindex='-1'><img src='/assets/magnifying_glass_small.png' class='plus_icon'></a>" +
                "&nbsp;<span id='person_" + jq_index + "'></span>" +
                "<input type='hidden' id='person_" + jq_index + "_hidden' value='' name='entry[related_person_groups_attributes][" + jq_index + "][person_same_as]'>" +
                "</td></tr>" +

                // Gender
                "<tr><th>Gender:</th><td><select name='entry[related_person_groups_attributes][" + jq_index + "][person_gender]'>" + gender_options + "</select></td></tr>" +

                // Role
                "<tr><th style='width: 110px'>Person Role:" +
                "&nbsp;<img jq_role_list=" + jq_role_list + " jq_type='" + "person_role" + "' jq_index='" + jq_index + "' jq_attributes='related_person_groups_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Descriptor
                "<tr><th style='width: 110px'>Descriptor:" +
                "&nbsp;<img jq_descriptor_list=" + jq_descriptor_list + " jq_type='" + "person_descriptor" + "' jq_index='" + jq_index + "' jq_attributes='related_person_groups_attributes' class='plus_icon click_select_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Descriptor As Written
                "<tr><th style='width: 110px'>Descriptor As Written:" +
                "&nbsp;<img jq_type='person_descriptor_as_written' jq_index='" + jq_index + "' jq_attributes='related_person_groups_attributes' class='plus_icon click_multiple_field_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Note
                "<tr><th>Note:" +
                "&nbsp;<img jq_type='person_note' jq_index='" + jq_index + "' jq_attributes='related_person_groups_attributes' class='plus_icon click_multiple_text_area_button_level2' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Related Place
                "<tr><th>Related Place:" +
                "&nbsp;<img jq_type='person_related_place' jq_index='" + jq_index + "' jq_attributes='related_person_groups_attributes' class='plus_icon click_related_place_field_button' src='/assets/plus_sign.png'>" +
                "</th><td><div class='field_group grey_box'></div></td></tr>" +

                // Hidden field for RDFTYPE
                "<tr><input type='hidden' id='hidden_field' name='entry[related_person_groups_attributes][" + jq_index + "][rdftype]' value='" + jq_rdftype + "'></tr>" +

                "</table>" +
                "<img src='/assets/delete.png' alt='Delete icon' class='delete_icon click_remove_field_level2' params_type='related_person_groups'>" +
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
            var jq_date_role_list = $.parseJSON($(this).attr('jq_date_role_list')) // See note on line above
            var jq_date_certainty_list = $(this).attr('jq_date_certainty_list').replace(/ /g, "&#32;");  // Appears to be a problem when list is added as a nested list, i.e. Level 2, therefore replace them here
            var jq_single_date_list = $(this).attr('jq_single_date_list').replace(/ /g, "&#32;"); // See note on line above
            var jq_rdftype = $(this).attr('jq_rdftype')

            var date_role_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_date_role_list.length; i++) {
                date_role_options = date_role_options + "<option value='" + jq_date_role_list[i].id + "'>" + jq_date_role_list[i].label + "</option/>";
            }

            var new_code_block = "<div class='field_single no_padding'>" +

                "<table class='tab3' cellspacing='0'>" +

                    // Date
                "<tr><th>Date:&nbsp;<img jq_rdftype='[\"http://dlib.york.ac.uk/ontologies/borthwick-registers#SingleDate\"]' jq_date_certainty_list='" + jq_date_certainty_list + "' jq_single_date_list='" + jq_single_date_list + "' jq_index='" + jq_index + "' class='plus_icon click_single_date_button' src='/assets/plus_sign.png'></th><td><div class='field_group grey_box single_date'></div></td></tr>" +

                    // Date Role
                "<tr><th>Date Role:</th><td><select name='entry[entry_dates_attributes][" + jq_index + "][date_role]'>" + date_role_options + "</select></td></tr>" +

                    // Note
                "<tr><th>Note:</th><td class='input_single'><textarea value='' id='' name='entry[entry_dates_attributes][" + jq_index + "][date_note]'/></td></tr>" +

                // Hidden field for RDFTYPE
                "<tr><input type='hidden' id='hidden_field' name='entry[entry_dates_attributes][" + jq_index + "][rdftype]' value='" + jq_rdftype + "'></tr>" +

                "</table>" +
                "<img src='/assets/delete.png' alt='Delete icon' class='delete_icon click_remove_field_level2' params_type='entry_dates'>" +
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
            var jq_date_certainty_list = $(this).attr('jq_date_certainty_list'); //.replace(/ /g, "&#32;"); // Doesn't like spaces but quotes are OK?!
            var jq_single_date_list = $.parseJSON($(this).attr('jq_single_date_list')); //.replace(/ /g, "&#32;"); // Doesn't like spaces but quotes are OK?!
            var jq_rdftype = $(this).attr('jq_rdftype')

            var single_date_options = "<option value=''>--- select ---</option>";

            for (i = 0; i < jq_single_date_list.length; i++) {
                single_date_options = single_date_options + "<option value='" + jq_single_date_list[i] + "'>" + jq_single_date_list[i] + "</option/>";
            }


            var new_code_block = "<div class='field_single'>" +

                "<table>" +

                    // Date
                "<tr><th style='width: 120px'>Date (yyyy/mm/dd):</th>" +
                "<td class='input_single'><input id='' type='text' name='entry[entry_dates_attributes][" + jq_index + "][single_dates_attributes][" + jq_index2 + "][date]'></td>" +

                    // Date Certainty
                "<tr><th style='width: 110px'>Certainty:&nbsp;" +
                "<img src='/assets/plus_sign.png' alt='plus icon' class='plus_icon click_select_field_button_date_certainty' jq_index='" + jq_index + "' jq_index2='" + jq_index2 + "' jq_date_certainty_list='" + jq_date_certainty_list + "'/>" +
                "</th><td><div class='field_group_date_certainty grey_box'></div></td></tr>" +

                    // Type
                "<tr><th>Type:</th>" +
                "<td><select name='entry[entry_dates_attributes][" + jq_index + "][single_dates_attributes][" + jq_index2 + "][date_type]'>" + single_date_options + "</select></td>" +

                    // Hidden field for RDFTYPE
                "<tr><input type='hidden' id='hidden_field' name='entry[entry_dates_attributes][" + jq_index + "][single_dates_attributes][" + jq_index2 + "][rdftype]' value='" + jq_rdftype + "'></tr>" +

                "</table>" +
                "<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_date' jq_index1='" + jq_index2 + "'>" +
                "<div style='clear: both'></div></div>";

            $(this).parent('th').next('td').find('.field_group').append(new_code_block);

        } catch (err) {
            alert(err);
        }
    });

    // Click add date certainty button
    $('body').on('click', '.click_select_field_button_date_certainty', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var jq_attributes = $(this).attr('jq_attributes');
            var jq_index = $(this).attr('jq_index');
            var jq_index2 = $(this).attr('jq_index2');
            var jq_type = $(this).attr('jq_type');
            var options = "<option value=''>--- select ---</option>";
            var list_array = $.parseJSON($(this).attr('jq_date_certainty_list')); //.replace(/ /g, "&#32;");

            for (i = 0; i < list_array.length; i++) {
                options = options + "<option value='" + list_array[i] + "'>" + list_array[i] + "</option/>";
            }

            var new_code_block = "<div class='field_single'><select name='entry[entry_dates_attributes][" + jq_index + "][single_dates_attributes][" + jq_index2 + "][date_certainty][]'>" + options +
                "</select>&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon_select click_remove_field_level1' jq_tag_type='select'></div>";

            $(this).parent('th').next('td').find('.field_group_date_certainty').append(new_code_block);
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

            // Delete the value from the field
            if ($(this).attr('jq_tag_type') == 'select') {
                field_single_div.find('select').val('');
            } else if ($(this).attr('jq_tag_type') == 'input') {
                field_single_div.find('input').val('');
            } else if ($(this).attr('jq_tag_type') == 'textarea') {
                field_single_div.find('textarea').val('');
            }

            // Update the person 'Related Place' list because an element which is removed shouldn't be shown
            update_related_places();

        } catch (err) {
            alert(err);
        }
    });

    // This code hides Level 2 elements, i.e. Entry Date, Related Place and Related Person Group elements
    // Note that a hidden field is also added with '_destroy' = '1' - this is necessary to remove associations in Fedora
    $('body').on('click', '.click_remove_field_level2', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_single_div = $(this).parent('div');
            field_single_div.css({'display': 'none'});

            // Add a '_destroy' = '1' hidden element to make sure that the block is deleted from Fedora
            // To do this, need to find out the index of the element we are using
            // To get the correct index, the code uses the hidden 'input' field for 'Place Name Authority' for 'Related Place',
            // the 'Person Name Authority' field for 'Related Person Group'
            // and the 'Note' field for 'Entry Date'
            // If these fields change, this code will have to be modified
            var params_type = $(this).attr('params_type');
            var target_tag = '';

            if (params_type == 'entry_dates') {
                target_tag = field_single_div.find('textarea');
            } else {
                target_tag = field_single_div.find('input');
            }

            // Add the hidden field with 'destroy=1' so that this element is deleted when the form is submitted
            field_single_div.append("<input type='hidden' name='entry[" + params_type + "_attributes][" + get_index(target_tag.attr('name')) + "][_destroy]' value='1'>");

            // Remove the Place As Written value because otherwise it will appear in the 'Related Places' drop-down list
            if (params_type == 'related_places') {
                place_as_written_input = field_single_div.find('.place_as_written');
                place_as_written_input.css('border', '1px solid green');
                place_as_written_input.val('');
            }

            // Update the person 'Related Place' list because this element has been removed and shouldn't be in the drop-down list
            update_related_places();

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

    // Click multiple field button on person / place popup
    $('body').on('click', '.click_popup_multiple_field_button', function (e) {

        try {
            e.preventDefault(); // I think this prevents other events firing?
            var field_group_div = $(this).parent('th').next('td').find('>:first-child');
            //field_group_div.css("border", "1px solid red");
            var jq_type_1 = $(this).attr('jq_type_1');
            var jq_type_2 = $(this).attr('jq_type_2');
            var new_code_block = "<div class='field_single'>"
                + "<input type='text' value='' name='" + jq_type_1 + "[" + jq_type_2 + "][]'>"
                + "&nbsp;<img alt='Delete icon' src='/assets/delete.png' class='delete_icon click_remove_field_level1' jq_tag_type='input'>"
                + "</div>";
            field_group_div.append(new_code_block);
        } catch (err) {
            alert(err);
        }
    });

    // Calls the function below when a place_as_written is changed (or added)
    $('body').on('change', '.place_as_written', function(e) {
        update_related_places();
    });

    var form_modified = 0;

    $('#form_modified *').change(function(){
        form_modified = 1;
    });

    window.onbeforeunload = confirmExit;

    function confirmExit() {
        if (form_modified == 1) {
            return "New information not saved. Do you wish to leave the page?";
        }
    }

    $("input[name='commit']").click(function() {
        form_modified = 0;
    });


    $("#popup_info").dialog({
        autoOpen: false,
        draggable: false,
        resizable: false,
        position: { my: "center", at: "top+60px", of: window },
        width: '740px',
        height: 50,
        show: {
            effect: 'fade',
            duration: 750
        },
        hide: {
            effect: 'fade',
            duration: 3000
        },
        open: function(){
            $(this).dialog('close');
        },
        close: function(){
            $(this).dialog('destroy');
        }
    });

    $(".ui-dialog-titlebar").remove();

    // Finally open the dialog! The open function above will run once
    // the dialog has opened. It runs the close function! After it has
    // faded out the dialog is destroyed
    $("#popup_info").dialog("open");


});

// This is called if the user changes a place 'As Written' field or the user adds a new place
// It updates all the person 'Related Place' drop-down lists by adding new terms and removing old terms
// Note that I tried to do it when the user actually clicked on the 'Related Place' list but there was
// a problem with removing elements and someone on StackOverflow said that the options are being
// destroyed every time and that's why you can't select from the list - see here:
// http://stackoverflow.com/questions/30736354/choosing-options-after-dynamically-changing-a-select-list-with-jquery/30737208#30737208
// Note that this code also relies on a 'place_as_written' class and 'place_as_written_block' class
// which are put on the appropriate divs
function update_related_places() {

    try {

        var place_as_written_array = new Array();

        // Get all the Place As Written values into an array
        // nOte that we only look for the first value which is not equal to '' because there can be more than one
        $('.place_as_written_block').each(function (index) {

           var place_as_written_class = $(this).find('.place_as_written')

           place_as_written_class.each(function() {

               place_as_written_value = $(this).val();

               if (place_as_written_value != '') {
                   place_as_written_array[index] = place_as_written_value;
                   return false;
               }
           });
        });

        // Firstly, remove any 'Related Place' options which don't exist anymore in the place 'As Written' text fields
        $('.related_place').each(function () {

            var select_tag = $(this);

            //console.log("\n\n");

            select_tag.find('option').each(function () {

                var exists = false;

                var option_tag = $(this);
                var related_place_text = option_tag.text(); // Use text rather than value because '--- select ---' doesn't have a value

                $.each(place_as_written_array, function (index, place_as_written_value) {

                    if (related_place_text == place_as_written_value) {
                        exists = true
                    }
                });

                if (exists == false && related_place_text != "--- select ---") {
                    option_tag.remove();
                }
            });
        });

        // Secondly, append the place 'As Written' fields to the 'Related Place' drop_down lists (if they don't already exist)
        if (place_as_written_array.length > 0) {

            $.each(place_as_written_array, function (index, place_as_written_value) {

                $('.related_place').each(function () {

                    var exists = false
                    var select_tag = $(this)

                    select_tag.find('option').each(function () {
                        var related_place_value = $(this).val();

                        if (place_as_written_value == related_place_value) {
                            exists = true;
                        }
                    });

                    // Add the option if it doesn't exist.
                    if (exists == false && place_as_written_value != null) {
                        select_tag.append("<option value='" + place_as_written_value + "'>" + place_as_written_value + "</option>");
                    }
                });
            });
        }

    } catch (err) {
        alert(err);
    }
}
