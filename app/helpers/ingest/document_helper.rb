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
        # pry(main)> Ingest::DocumentHelper.s_get_document_json('1257b485h', 'C 81/1786/43')
        # => "2b88qc56f"
        def self.s_get_document_json(series_id, reference)
            document_json = nil

            unless series_id.nil? or reference.nil?
                query = "has_model_ssim:Document AND series_ssim:#{series_id} AND reference_tesim:\"#{reference}\""
                SolrQuery.new.solr_query(query, '')['response']['docs'].map do |r|
                    document_json = r
                end
            end

            document_json
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
            document_types,
            date_of_document,
            place_of_dating,
            language,
            subject,
            addressees,
            senders,
            persons,
            place)
            log = Logger.new "log/document_helper.log"

            # store sub object ids and use them to link sub objects to document later
            place_of_dating_ids = []
            tna_place_ids = []
            tna_addressee_ids = []
            tna_sender_ids = []
            tna_person_ids = []
            document_date_ids = []

            document_json = s_get_document_json(series_id, reference)
            document_id = nil
            document_id = document_json['id'] unless document_json.nil?

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
            d.document_type = Ingest::AuthorityHelper.s_get_entry_type_object_ids(document_types) unless document_types.blank?

            # Date of document
            document_date_role = ''
            document_date_note = entry_date_note || ''
            document_date  = Ingest::DocumentDateHelper.create_document_date(document_id,
                                                                             document_date_role,
                                                                             document_date_note)
            unless document_date.blank?
                multi_date_seperator = '-'
                if date_of_document.include? 'x'
                    multi_date_seperator = 'x'
                end
                number_of_single_dates = date_of_document.split(multi_date_seperator).length()
                date_of_document.split(multi_date_seperator).each_with_index do |date_string,index|
                    # default certainty field is 'certain'
                    certainties = []

                    # default date type is 'single'
                    date_type = 'single'
                    if number_of_single_dates > 1
                        date_type = index==0? 'start':'end'
                    end

                    # for dates in format: [? 1408]/10/20
                    if date_string.include? '?'
                        certainties << 'uncertain'
                    end
                    if date_string.include? '[' or date_string.include? ']'
                        certainties << 'inferred'
                    end

                    # remove other characters from Year, Month, and Day
                    date_array = date_string.split('/')
                    date_string = date_array[0].tr('^0-9', '') + '/' + date_array[1].tr('^0-9', '') + '/' + date_array[2].tr('^0-9', '')

                    document_date_ids << document_date.id
                    d.document_date_ids << document_date.id

                    if certainties.blank?
                        certainties = ['certain']
                    end
                    single_date = Ingest::DocumentDateHelper.create_single_date(
                        document_date,
                        date_string || '',
                        certainties,
                        date_type)
                    document_date.single_date_ids << single_date.id unless single_date.blank?
                end
            end

            # Language
            d.language = Ingest::AuthorityHelper.s_get_language_object_ids(language) unless language.blank?

            # Subject
            subjects = []
            if subject.include? ';'
                subjects = subject.split(';')
            else
                subjects = [subject]
            end
            d.subject = Ingest::AuthorityHelper.s_get_subject_object_ids(subjects) unless subjects.blank?

            place_of_datings = []
            place_of_dating_descs = Ingest::ExcelHelper.extract_places_info(place_of_dating, 'place of dating', '')
            place_of_dating_descs.each do |place_of_dating_desc|
                place_of_dating_id = ''
                place_authority_ids = []

                # Place name could be empty
                # if it's the case, then only add place_written_as and
                # add place_note with text: "place unidentified"
                # See implementation in excel_helper.extract_place_info
                unless place_of_dating_desc.place_name.blank?
                    place_authority_ids = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                        place_of_dating_desc.place_name,
                        place_of_dating_desc.county,
                        place_of_dating_desc.country)
                    # allow empty place names, so possibly we could have empty place_authority_ids
                    if place_authority_ids.blank? or place_authority_ids.length()==0
                        puts '  Place of dating warning: cannot find placeofdating.place_authority id'
                        puts place_of_dating_desc.place_name
                        puts place_of_dating_desc.county
                        puts "  >>> #{reference}..."
                        # return
                    elsif place_authority_ids.length() > 1
                        puts '  -------------------------------------'
                        puts '  -------------------------------------'
                        puts '  Place of dating Error: returns more than 1 places.'
                        puts "  >>> #{reference}..."
                        puts place_authority_ids
                        puts '  -------------------------------------'
                        puts '  -------------------------------------'
                        # next
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
                        # puts '  2. create Place of dating: ' + place_of_dating.id
                    else # if found, use existing Place of Dating
                        # puts '  3. Found Place of dating ' + place_of_dating_id
                        place_of_dating = PlaceOfDating.find(place_of_dating_id)
                    end
                end

                # place_of_datings << place_of_dating
                place_of_dating_ids << place_of_dating_id
            end

            unless place.blank?
                place_descs = Ingest::ExcelHelper.extract_places_info(place, 'place mentioned', '')
                place_descs.each do |place_desc|
                    place_authority_ids = []
                    # allow place_name to be empty
                    tna_place_id = ''
                    unless place_desc.blank? or place_desc.place_name.blank?
                        place_authority_ids = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                            place_desc.place_name,
                            place_desc.county,
                            place_desc.country)
                        if place_authority_ids.blank?
                            puts '  Place(s) Warn: cannot find tna_place.place_authority id'
                            puts '    ' + place_desc.place_name
                            puts '    ' + place_desc.county
                            puts "  >>> #{reference}..."
                        elsif place_authority_ids.length()>1
                            puts '  Place(s) Error: returns more than 1 tna_place.places.'
                            puts "  >>> #{reference}..."
                        end
                    end

                    # if document id is blank, means it is a new document,
                    # so definitely needs to create a new Tna Place
                    unless place_desc.blank?
                        if d.id.blank?
                            tna_place = Ingest::TnaPlaceHelper.create_tna_place(
                                d.id,
                                place_desc.place_as_written,
                                place_authority_ids,
                                [place_desc.place_role],
                                [place_desc.place_note])
                            tna_place_id = tna_place.id
                            # puts '1. created tna place: ' + tna_place.id
                        else
                            # try to find existing tna place object
                            current_place_authority_id = nil
                            current_place_authority_id = place_authority_ids[0] unless place_authority_ids.blank? or place_authority_ids.length()==0
                            tna_place_id = Ingest::TnaPlaceHelper.get_tna_place_id(
                                d.id,
                                current_place_authority_id,
                                place_desc.place_as_written)
                            # if NOT found tna_place, create a new one
                            if tna_place_id.blank?
                                tna_place = Ingest::TnaPlaceHelper.create_tna_place(
                                    d.id,
                                    place_desc.place_as_written,
                                    place_authority_ids,
                                    [place_desc.place_role],
                                    place_desc.place_note.nil? ? []: [place_desc.place_note])
                                tna_place_id = tna_place.id
                                # puts '  2. created tna place: ' + tna_place.id
                                # else # if found, use existing Tna Place
                                #     puts '3. found tna place: ' + tna_place_id
                            end
                        end
                    end
                    tna_place_ids << tna_place_id
                end
            end

            # addressee
            if d.id.blank? # if a new document, definitely need to create a new tna addressee
                addressee_ids = Ingest::TnaPersonHelper.create_tna_addressee(nil, addressees)
                tna_addressee_ids += addressee_ids unless addressee_ids.nil?
                # puts '1. No doc id, creating tna addressee'
            else
                # try to find existing tna addressee object
                existing_addressee_ids = Ingest::TnaPersonHelper.s_get_tna_addressee_ids(d.id, addressees)
                if existing_addressee_ids.blank?
                    # puts '2. cannot find tna address, creating new one'
                    new_addressee_ids = Ingest::TnaPersonHelper.create_tna_addressee(d.id, addressees)
                    new_addressee_ids.each do |id|
                        tna_addressee_ids << id
                    end
                else
                    # puts '3. found tna addressee ids: '
                    # puts existing_addressee_ids
                    existing_addressee_ids.each do |id|
                        tna_addressee_ids << id
                    end
                end
            end

            # sender
            if d.id.blank? # if a new document, definitely need to create a new tna sender
                tna_sender_ids += Ingest::TnaPersonHelper.create_tna_sender(nil, senders)
                # puts '1. No doc id, creating tna sender'
            else
                # try to find existing tna sender object
                existing_sender_ids = Ingest::TnaPersonHelper.s_get_tna_sender_ids(d.id, senders)
                if existing_sender_ids.blank?
                    # puts '2. cannot find tna sender, creating new one'
                    new_sender_ids = Ingest::TnaPersonHelper.create_tna_sender(d.id, senders)
                    new_sender_ids.each do |id|
                        tna_sender_ids << id
                    end
                else
                    # puts '3. found tna sender ids: '
                    # puts existing_sender_ids
                    existing_sender_ids.each do |id|
                        tna_sender_ids << id
                    end
                end
            end

            # person
            if d.id.blank? # if a new document, definitely need to create a new tna person
                tna_person_ids += Ingest::TnaPersonHelper.create_tna_person(nil, persons)
                # puts '1. No doc id, creating tna person'
            else
                # try to find existing tna person object
                existing_person_ids = Ingest::TnaPersonHelper.s_get_tna_person_ids(d.id, persons)
                if existing_person_ids.blank?
                    # puts '2. cannot find tna person, creating new one'
                    new_person_ids = Ingest::TnaPersonHelper.create_tna_person(d.id, persons)
                    new_person_ids.each do |id|
                        tna_person_ids << id
                    end
                else
                    # puts '3. found tna person ids: '
                    # puts existing_person_ids
                    existing_person_ids.each do |id|
                        tna_person_ids << id
                    end
                end
            end
            d.save
            puts "  Created/updated Document: #{d.id}" unless d.nil?
            log.info "  Created/updated Document: #{d.id}" unless d.nil?

            if is_new_document
                # update place_of_datings
                puts '  updating place_of_datings'
                place_of_dating_ids.each do |pd_id|
                    unless pd_id.nil? or pd_id.blank?
                        pd = PlaceOfDating.find(pd_id)
                        pd.document_id = d.id
                        # puts 'updated place of dating: ' + pd.id
                        pd.save
                    end
                end

                # update tna_place
                puts '  updating tna places'
                tna_place_ids.each do |tp_id|
                    unless tp_id.nil? or tp_id.blank?
                        tp = TnaPlace.find(tp_id)
                        tp.document_id = d.id
                        # puts 'updated tna_places: ' + tp.id
                        tp.save
                    end
                end

                # update TNA addressee
                puts '  updating addressees'
                tna_addressee_ids.each do |addressee_id|
                    tna_addressee = TnaAddressee.find(addressee_id)
                    tna_addressee.document_id = d.id
                    tna_addressee.save
                end

                # update TNA sender
                puts '  updating senders'
                tna_sender_ids.each do |sender_id|
                    tna_sender = TnaSender.find(sender_id)
                    tna_sender.document_id = d.id
                    tna_sender.save
                end

                # update TNA person
                puts '  updating persons'
                tna_person_ids.each do |person_id|
                    tna_person = TnaPerson.find(person_id)
                    tna_person.document_id = d.id
                    tna_person.save
                end

                # update document date
                puts '  updating document dates'
                document_date_ids.each do |document_date_id|
                    document_date = DocumentDate.find(document_date_id)
                    document_date.document_id = d.id
                    document_date.save
                end
            end
            d
        end
    end
end