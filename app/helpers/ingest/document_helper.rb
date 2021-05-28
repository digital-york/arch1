require 'logger'

module Ingest
    module DocumentHelper
        # search department's id by the given document reference
        # The prefix 's_' is the convention here, means retrieving data from Solr
        def self.s_get_department_label(document_reference)
            reference.split(' ')[0]
        end

        # search series's id by the given document reference
        def self.s_get_series_label(document_reference)
            reference.split('/')[0].gsub(" ", "")
        end

        # find Document by series id and reference.
        # pry(main)> Ingest::DocumentHelper.s_find_document('1257b485h', 'C 81/1786/43')
        # => "2b88qc56f"
        def self.s_find_document(series_id, reference)
            document_id = nil

            unless series_id.nil? or reference.nil?
                query = "has_model_ssim:Document AND series_ssim:#{series_id} AND reference_tesim:\"#{reference}\""
                SolrQuery.new.solr_query(query)['response']['docs'].map do |r|
                    document_id = r['id']
                end
            end

            document_id
        end

        # Ingest::DocumentHelper.create_document
        def self.create_or_update_document(
            allow_edit,
            repository,
            series_id,
            reference,
            publication,
            summary,
            entry_date_note,
            note,
            document_type,
            date_of_document,
            place_of_dating,
            language,
            subject,
            addressee,
            sender,
            person,
            place)
            log = Logger.new "log/document_helper.log"

            document_id = s_find_document(series_id, reference)

            # if a new document, need to update linked object, e.g.
            # Place of Dating, TnaPlace back to the document id after the document being saved.
            is_new_document = false

            if document_id.nil?
                d = Document.new
                is_new_document = true
            else
                d = Document.find(document_id)
                puts '  found document ' + document_id
                log.info '  found document ' + document_id
                if allow_edit==false
                    return d
                end
            end

            d.repository = repository
            # add document rdf types
            d.rdftype = d.add_rdf_types
            # link document to Series
            d.series = Series.find(series_id)
            d.reference = reference
            d.publication = publication
            d.summary = summary
            d.entry_date_note = entry_date_note
            d.note = note
            d.document_type = document_type

            # d.date_of_document = date_of_document

            d.language = Ingest::AuthorityHelper.s_get_language_object_ids(language) unless language.blank?
            d.subject = subject unless subject.blank?

            place_of_datings = []
            place_of_dating_descs = Ingest::ExcelHelper.extract_places_info(place_of_dating, 'place of dating', '')
            place_of_dating_descs.each do |place_of_dating_desc|
                place_authority_ids = []

                # Place name could be empty
                # if it's the case, then only add place_written_as and
                # add place_note with text: "place unidentified"
                # See implementation in excel_helper.extract_place_info
                unless place_of_dating_desc.place_name.blank?
                    place_authority_ids = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                        place_of_dating_desc.place_name,
                        place_of_dating_desc.county,
                        place_of_dating_desc.country) unless place_of_dating_desc.place_name.blank?
                    # allow empty place names, so possibly we could have empty place_authority_ids
                    if place_authority_ids.blank? or place_authority_ids.length()==0
                        puts 'Place of dating warning: cannot find place_authority id'
                        puts ">>> #{reference}..."
                        return
                    elsif place_authority_ids.length() > 1
                        puts 'Place of dating Error: returns more than 1 places.'
                        puts ">>> #{reference}..."
                        puts place_authority_ids
                        return
                    end
                end

                # if document id is blank, means it is a new document,
                # so definitely needs to create a new Place of dating
                place_of_dating_id = ''
                if d.id.blank?
                    # puts '1. create Place of Dating'
                    place_of_dating = Ingest::PlaceOfDatingHelper.create_place_of_dating(
                        d.id,
                        place_of_dating_desc.place_as_written,
                        place_authority_ids,
                        ['place of dating'],
                        place_of_dating_desc.place_note)
                    place_of_dating_id = place_of_dating.id
                else
                    # try to find existing place of dating object
                    place_of_dating_id = Ingest::PlaceOfDatingHelper.get_place_of_dating_id(
                                               d.id,
                                               place_authority_ids[0],
                                               place_of_dating_desc.place_as_written)
                    # if NOT found place_of_dating, create a new one
                    if place_of_dating_id.blank?
                        place_of_dating = Ingest::PlaceOfDatingHelper.create_place_of_dating(
                            d.id,
                            place_of_dating_desc.place_as_written,
                            place_authority_ids,
                            ['place of dating'],
                            place_of_dating_desc.place_note)
                        place_of_dating_id = place_of_dating.id
                        puts '2. create Place of dating: ' + place_of_dating.id
                    else # if found, use existing Place of Dating
                        puts '3. Found Place of dating ' + place_of_dating_id
                        place_of_dating = PlaceOfDating.find(place_of_dating_id)
                    end
                end

                # place_of_datings << place_of_dating
                d.place_of_dating_ids << place_of_dating_id
            end

            unless place.blank?
                tna_place_ids = []
                place_descs = Ingest::ExcelHelper.extract_places_info(place, '', '')
                place_descs.each do |place_desc|
                    place_authority_ids = []
                    # allow place_name to be empty
                    unless place_desc.place_name.blank?
                        place_authority_ids = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                            place_desc.place_name,
                            place_desc.county,
                            place_desc.country)

                        if place_authority_ids.blank?
                            puts 'Place(s) Warn: cannot find place_authority id'
                            puts ">>> #{reference}..."
                            return
                        elsif place_authority_ids.length()!=1
                            puts 'Place(s) Error: returns more than 1 places.'
                            puts ">>> #{reference}..."
                            return
                        end
                    end

                    # if document id is blank, means it is a new document,
                    # so definitely needs to create a new Tna Place
                    tna_place_id = ''
                    if d.id.blank?
                        tna_place = Ingest::TnaPlaceHelper.create_tna_place(
                            d.id,
                            place_desc.place_as_written,
                            place_ids,
                            place_desc.place_role,
                            place_desc.place_note)
                        tna_place_id = tna_place.id
                        # puts '1. created tna place: ' + tna_place.id
                    else
                        # try to find existing tna place object
                        tna_place_id = Ingest::TnaPlaceHelper.get_tna_place_id(
                            d.id,
                            place_authority_ids[0],
                            place_desc.place_as_written) unless place_authority_ids.blank?
                        # if NOT found tna_place, create a new one
                        if tna_place_id.blank?
                            tna_place = Ingest::TnaPlaceHelper.create_tna_place(
                                d.id,
                                place_desc.place_as_written,
                                place_authority_ids,
                                place_desc.place_role,
                                place_desc.place_note)
                            tna_place_id = tna_place.id
                            puts '2. created tna place: ' + tna_place.id
                        else # if found, use existing Tna Place
                            puts '3. found tna place: ' + tna_place_id
                        end
                    end
                    d.tna_place_ids << tna_place_id
                end
            end

            d.save
            puts "  Created/updated Document: #{d.id}" unless d.nil?
            log.info "  Created/updated Document: #{d.id}" unless d.nil?

            if is_new_document
                # update place_of_datings
                d.place_of_dating_ids.each do |pd_id|
                    pd = PlaceOfDating.find(pd_id)
                    pd.document_id = d.id
                    # puts 'updated place of dating: ' + pd.id
                    pd.save
                end

                # update tna_place
                d.tna_place_ids.each do |tp_id|
                    tp = TnaPlace.find(tp_id)
                    tp.document_id = d.id
                    # puts 'updated tna_places: ' + tp.id
                    tp.save
                end
            end
            d
        end
    end
end