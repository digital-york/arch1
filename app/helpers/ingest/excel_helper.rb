require 'roo'

module Ingest
    module ExcelHelper
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
                document_row.reference = row[1]
                document_row.document_type = row[2]
                document_row.date_of_document = row[3]
                document_row.place_of_dating = row[4]
                document_row.language = row[5]
                document_row.subject = row[6]
                document_row.addressee = row[7]
                document_row.sender = row[8]
                document_row.person = row[9]
                document_row.place = row[10]
                document_row.summary = row[11]

                # As agreed, the endorsement will be deleted,
                # so double check the spreadsheet before running the script!
                document_row.publication = row[12]

                document_row.note = row[13]
                document_row.entry_date_note = row[14]

                # document_row.person_note no person_note in the agreed mode,
                # but there is a column in the 'TNA document indexing C81 test file'

                document_rows << document_row
            }

            document_rows
        end
    end
end