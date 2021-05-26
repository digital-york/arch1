require 'roo'
require 'caxlsx'

module Ingest
    module ExcelHelper
        # define default counties for TNA spreadsheet process
        DEFAULT_COUNTY = {
            "City of London" => "London",
            "City of York" => "York",
            "Westminster" => "Middlesex"
        }.freeze

        # parse a row from Borthwick spreadsheet
        def self.parse_borthwick_spreadsheet(filename)
            entry_rows = []
            entries = Roo::Spreadsheet.open(filename)
            entries.each_with_index { |entry, index|
                # Ignore the double header
                if index < 2
                    next
                end

                entry_row = Ingest::BorthwickEntryRow.new

                entry_row.register              = entry[0]
                # some folios end with 'a', 'b' etc
                if entry[1].to_s.ends_with? '.0'
                    entry_row.folio_no          = entry[1].to_i.to_s
                else
                    entry_row.folio_no          = entry[1].to_s
                end
                entry_row.folio_side            = entry[2]
                # for entries with multiple images, the entry no ends with letters ,e.g. 'a', 'b' etc
                if entry[3].to_s.ends_with? '.0'
                    entry_row.entry_no          = entry[3].to_i.to_s
                else
                    entry_row.entry_no          = entry[3].to_s
                end
                entry_row.entry_type1           = entry[4]
                entry_row.entry_type2           = entry[5]
                entry_row.entry_type3           = entry[6]
                entry_row.section_type          = entry[7]
                if entry[8].to_s.ends_with? '.0'
                    entry_row.continues_folio_no = entry[8].to_i.to_s
                else
                    entry_row.continues_folio_no = entry[8].to_s
                end
                entry_row.continues_folio_side  = entry[9]
                entry_row.continues_image_id    = entry[10]
                entry_row.summary               = entry[11]
                entry_row.marginalia            = entry[12]
                entry_row.language1             = entry[13]
                entry_row.language2             = entry[14]
                entry_row.subject1              = entry[15]
                entry_row.subject2              = entry[16]
                entry_row.subject3              = entry[17]
                entry_row.subject4              = entry[18]
                entry_row.note                  = entry[19]
                entry_row.referenced_by         = entry[20]
                entry_row.entry_date1_date      = entry[21]
                entry_row.entry_date1_certainty = entry[22]
                entry_row.entry_date1_type      = entry[23]
                entry_row.entry_date1_date_role = entry[24]
                entry_row.entry_date1_note      = entry[25]
                entry_row.entry_date2_date      = entry[26]
                entry_row.entry_date2_certainty = entry[27]
                entry_row.entry_date2_type      = entry[28]
                entry_row.entry_date2_date_role = entry[29]
                entry_row.entry_date2_note      = entry[30]
                entry_row.place_as              = entry[31]
                entry_row.place_name            = entry[32]
                entry_row.place_role            = entry[33]
                entry_row.place_type            = entry[34]
                entry_row.place_note            = entry[35]
                entry_row.image_id              = entry[36]
                entry_row.group1_as_written     = entry[37]
                entry_row.group1_person_or      = entry[38]
                entry_row.group1_group          = entry[39]
                entry_row.group1_gender         = entry[40]
                entry_row.group1_person_role    = entry[41]
                entry_row.group1_descriptor     = entry[42]
                entry_row.group1_note           = entry[43]
                entry_row.group2_as_written     = entry[44]
                entry_row.group2_person_or      = entry[45]
                entry_row.group2_group          = entry[46]
                entry_row.group2_gender         = entry[47]
                entry_row.group2_person_role    = entry[48]
                entry_row.group2_descriptor     = entry[49]
                entry_row.group2_note           = entry[50]
                entry_row.person1_as_written    = entry[51]
                entry_row.person1_person_group  = entry[52]
                entry_row.person1_people_name   = entry[53]
                entry_row.person1_gender        = entry[54]
                entry_row.person1_person_role   = entry[55]
                entry_row.person1_descriptor    = entry[56]
                entry_row.person1_note          = entry[57]
                entry_row.person2_as_written    = entry[58]
                entry_row.person2_person_group  = entry[59]
                entry_row.person2_people_name   = entry[60]
                entry_row.person2_gender        = entry[61]
                entry_row.person2_person_role   = entry[62]
                entry_row.person2_descriptor    = entry[63]
                entry_row.person2_note          = entry[64]
                entry_row.person3_as_written    = entry[65]
                entry_row.person3_person_group  = entry[66]
                entry_row.person3_people_name   = entry[67]
                entry_row.person3_gender        = entry[68]
                entry_row.person3_person_role   = entry[69]
                entry_row.person3_descriptor    = entry[70]
                entry_row.person3_note          = entry[71]

                entry_rows << entry_row
            }

            entry_rows
        end

        # parse a row from TNA spreadsheet
        def self.parse_tna_spreadsheet(filename)
            document_rows = []
            rows = Roo::Spreadsheet.open(filename)
            rows.each_with_index { |row, index|
                # Ignore the first tow rows (header)
                if index < 2
                    next
                end

                document_row = Ingest::TnaDocumentRow.new

                document_row.repository = row[0]
                document_row.department = row[1]
                document_row.series = row[2]
                document_row.reference = row[3]
                document_row.document_type = row[4]
                document_row.date_of_document = row[5]
                document_row.place_of_dating = row[6]
                document_row.language = row[7]
                document_row.subject = row[8]
                document_row.addressee = row[9]
                document_row.sender = row[10]
                document_row.person = row[11]
                document_row.place = row[12]
                document_row.summary = row[13]
                document_row.publication = row[14]
                document_row.note = row[15]
                document_row.entry_date_note = row[16]

                # document_row.person_note no person_note in the agreed mode,
                # but there is a column in the 'TNA document indexing C81 test file'

                document_rows << document_row
            }

            document_rows
        end

        # normalize TNA spreadsheet
        # This method is ONLY used for data preprocess and testing
        # e.g. Ingest::ExcelHelper.preprocess_tna_spreadsheet('/home/frank/dlib/nw_data/tna_c81.xlsx', '/home/frank/dlib/nw_data/tna_c81_new.xlsx')
        def self.preprocess_tna_spreadsheet(src_file, tgt_file)
            src_rows = Roo::Spreadsheet.open(src_file)
            total_number_of_place_of_dating = get_max_number_of_place_of_dating(src_rows)
            total_number_of_place = get_number_of_place(src_rows)
            p = Axlsx::Package.new
            wb = p.workbook
            wb.add_worksheet do |sheet|
                src_rows.each_with_index { |src_row, index|
                    sheet.add_row transform_tna_rows(src_row,
                                                     index,
                                                     total_number_of_place_of_dating,
                                                     total_number_of_place)
                }
            end

            p.serialize tgt_file
        end

        # return number of place of datings in the single 'place of dating' column from TNA spreadsheet
        def self.get_max_number_of_place_of_dating(src_rows)
            max_number_of_place_of_dating = 0
            src_rows.each do |row|
                unless row[6].blank?
                    if row[6].split(';').length() > max_number_of_place_of_dating
                        max_number_of_place_of_dating = row[6].split(';').length()
                    end
                end
            end
            max_number_of_place_of_dating
        end

        # return number of places in the single 'Place(s)' column from TNA spreadsheet
        def self.get_number_of_place(src_rows)
            max_number_of_place = 0
            src_rows.each do |row|
                unless row[12].blank?  # check Place(s) column in TNA spreadsheet
                    if row[12].split(';').length() > max_number_of_place
                        max_number_of_place = row[12].split(';').length()
                    end
                end
            end
            max_number_of_place
        end

        # transform TNA row
        def self.transform_tna_rows(row, index, total_number_of_place_of_dating, total_number_of_place)
            # ignore title (index=0) and sub title (index=1)
            if index > 1
                process_tna_row(row, total_number_of_place_of_dating, total_number_of_place)
            end
            row
        end

        # process TNA spreadsheet row, e.g. add additional columns for place_of_dating and place column
        def self.process_tna_row(row, max_number_of_place_of_dating, total_number_of_place)
            # process column 6, Place of dating(s)
            process_place_string(row, 6, max_number_of_place_of_dating)

            ##################################
            # process column 12, Place(s)
            process_place_string(row, 12, total_number_of_place)

            row
        end

        # process place cell string and update cell with reorganized string
        def self.process_place_string(row, index, max_number_of_place)
            place_cell = row[index]

            place_descs = extract_places_info(place_cell, 'place of dating', '')

            updated_place_of_dating = ""
            place_descs.each_with_index do |place_desc, n|
                place_name = place_desc.place_name
                place_as_written = place_desc.place_as_written
                county = place_desc.county
                country = place_desc.country

                unless place_name.blank?
                    updated_place_of_dating += place_name
                end
                unless place_as_written.blank?
                    updated_place_of_dating += " (#{place_as_written}), "
                else
                    updated_place_of_dating += ","
                end
                unless county.blank?
                    updated_place_of_dating += county + ","
                end
                unless country.blank?
                    updated_place_of_dating += country + ","
                end
                if updated_place_of_dating.ends_with? ","
                    updated_place_of_dating = updated_place_of_dating.delete_suffix(",")
                end
                if n < max_number_of_place-1
                    updated_place_of_dating += " / "
                end
            end
            row[index] = updated_place_of_dating
        end


        # extract place info from a single string, e.g.
        # From: Kirkstall (Kyrkestall) abbey, West Riding of Yorkshire
        # to a PlaceDesc object
        # Usage: Ingest::ExcelHelper.extract_place_info('Kirkstall (Kyrkestall) abbey, West Riding of Yorkshire', 'place of dating', '')
        def self.extract_place_info(place_string, place_role, place_type)
            # remove spaces from both sides
            place_string.strip!

            place_parts = place_string.split(',')
            place_name_and_written_as = place_parts[0]

            place_as_written = ''
            place_name = ''
            place_note = ''
            if place_name_and_written_as.include? '(' and place_name_and_written_as.include? ')'
                # with completely unidentified placenames,
                # I've simply put them in (round brackets),
                # so that the name goes into the 'As written' field,
                # but without any other info - there won't be an authority.
                if place_name_and_written_as.starts_with? '(' place_name_and_written_as.ends_with? ')'
                    place_name = ''
                    place_as_written = place_name_and_written_as[1..place_name_and_written_as.length-2]
                    place_note = 'place unidentified'
                else
                    place_as_written = place_name_and_written_as.split('(')[1].split(')')[0]
                    place_name = place_name_and_written_as.gsub(place_as_written,'')
                                     .gsub('(','')
                                     .gsub(') ','')
                                     .gsub(')','')
                end
            else
                place_name = place_name_and_written_as
            end
            county = (place_parts[1] || '').gsub(';','')
            if county.blank?
                county = get_default_county(place_name)
            end
            country = place_parts[2] || ''
            place_as_written.strip!
            place_name.strip!
            county.strip!
            country.strip!
            tna_place_desc = Ingest::TnaPlaceDesc.new(place_as_written,
                                  place_name,
                                  place_role,
                                  place_type,
                                  county,
                                  country,
                                  place_note)
            tna_place_desc
        end

        # extract a group of place_strings(seperated by ';') into a TnaPlaceDesc array
        # e.g.
        # Ingest::ExcelHelper.extract_places_info('Malton priory, North Riding of Yorkshire; Watton priory, East Riding of Yorkshire; Haverholme priory, Lincolnshire;','','')
        def self.extract_places_info(place_strings, place_role, place_type)
            tna_place_desc_array = []
            return tna_place_desc_array if place_strings.blank?
            place_strings.split(';').each do |place_string|
                place_info = Ingest::ExcelHelper.extract_place_info(place_string, place_role, place_type) unless place_string.blank?
                tna_place_desc_array << place_info
            end
            tna_place_desc_array
        end

        def self.get_default_county(city)
            DEFAULT_COUNTY.each do |current_city, current_county|
                return current_county if city.downcase == current_city.downcase
            end
            return ""
        end
    end
end