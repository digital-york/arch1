require 'logger'

module Ingest
    # This class build a Document from TnaDocumentRow object
    class TnaDocumentBuilder

        def self.build_document(tna_document_row, allow_edit=false)
            log = Logger.new "log/tna_document_builder.log"

            repository = tna_document_row.repository

            # document reference
            reference = tna_document_row.reference

            department_label = reference.split(' ')[0]
            department_id = Ingest::DepartmentHelper.s_get_department_id(department_label)
            if department_id.nil?
                puts 'cannot find department for: ' + reference
                log.info 'cannot find department for: ' + reference
                return nil
            end

            series_label = reference.split('/')[0].gsub(" ", "")
            series_id = Ingest::SeriesHelper.s_get_series_id(department_id, series_label)
            if series_id.nil?
                puts 'cannot find series for: ' + reference
                log.info 'cannot find series: ' + reference
                return nil
            end

            # publications
            publications = []
            publications = [tna_document_row.publication] unless tna_document_row.publication.blank?

            summary = tna_document_row.summary unless tna_document_row.summary.blank?

            entry_date_notes = []
            entry_date_notes = [tna_document_row.entry_date_note] unless tna_document_row.entry_date_note.blank?

            notes = []
            notes = [tna_document_row.note] unless tna_document_row.note.blank?

            document_types = []
            document_types = [tna_document_row.document_type] unless tna_document_row.document_type.blank?

            date_of_documents = ''
            date_of_documents = tna_document_row.date_of_document unless tna_document_row.date_of_document.blank?

            place_of_dating = tna_document_row.place_of_dating unless tna_document_row.place_of_dating.blank?

            languages = []
            if tna_document_row.language.blank?
                languages << 'Latin'
            else
                languages << tna_document_row.language
            end

            # subject
            subjects = []
            subjects << tna_document_row.subject unless tna_document_row.subject.blank?

            # addressees
            addressees = []
            unless tna_document_row.addressee.blank?
                if tna_document_row.addressee.include? ";"
                    tna_document_row.addressee.split(";").each do |a|
                        addressees << a
                    end
                else
                    addressees << tna_document_row.addressee
                end
            end

            # senders
            senders = []
            unless tna_document_row.sender.blank?
                if tna_document_row.sender.include? ";"
                    tna_document_row.sender.split(";").each do |s|
                        senders << s
                    end
                else
                    senders << tna_document_row.sender
                end
            end

            # person
            persons = []
            unless tna_document_row.person.blank?
                if tna_document_row.person.include? ";"
                    tna_document_row.person.split(";").each do |p|
                        persons << p
                    end
                else
                    persons << tna_document_row.person
                end
            end

            # place
            place_string = ''
            place_string = tna_document_row.place unless tna_document_row.place.blank?

            d = Ingest::DocumentHelper.create_or_update_document(
                allow_edit,
                repository,
                series_id,
                reference,
                publications,
                summary,
                entry_date_notes,
                notes,
                document_types,
                date_of_documents,
                place_of_dating,
                languages,
                subjects,
                addressees,
                senders,
                persons,
                place_string
            )
        end

    end
end