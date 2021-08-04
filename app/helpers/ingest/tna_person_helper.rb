module Ingest
    # Provide helper methods for TNA addressee, sender, person
    # NB: the following methods are in complete
    #     they only record person data in as_written field
    #     e.g. not linking to Person authority due to tight deadlines
    #     (asked by project owner as the person/addressee/sender data won't be ready)
    module TnaPersonHelper

        @solr_server = SolrQuery.new

        # Ingest::TnaPersonHelper.create_tna_addressee(document_id, addresses)
        def self.create_tna_addressee(
            document_id,
            addressees)
            tna_addressee_ids = []

            addressees.each do |addressee|
                unless addressee.strip.blank?
                    tna_addressee = TnaAddressee.new

                    tna_addressee.rdftype = tna_addressee.add_rdf_types
                    tna_addressee.person_as_written = [addressee] unless addressee.blank?
                    tna_addressee.document_id = document_id unless document_id.blank?

                    tna_addressee.save
                    tna_addressee_ids << tna_addressee.id
                end
            end

            tna_addressee_ids
        end

        # pry(main)> Ingest::TnaPersonHelper.s_get_tna_addressee_ids(d.id,['Edward I, king of England'])
        # => ["4x51hx099"]
        def self.s_get_tna_addressee_ids(document_id, addressees)
            return nil if addressees.blank?

            addressee_ids = []
            addressees.each do |addressee|
                q = 'has_model_ssim:TnaAddressee AND person_as_written_tesim:"' + addressee.downcase + '"'
                q+= ' addresseeFor_ssim:' + document_id unless document_id.blank?
                resp = @solr_server.solr_query(q, 'id')
                resp['response']['docs'].map do |pobj|
                    addressee_ids << pobj['id']
                end
            end
            addressee_ids
        end

        # pry(main)> Ingest::TnaPersonHelper.s_get_linked_addressee_as_written_labels(d.id)
        def self.s_get_linked_addressee_as_written_labels(document_id)
            return nil if document_id.blank?

            addressee_labels = []

            q = 'has_model_ssim:TnaAddressee AND addresseeFor_ssim:' + document_id
            resp = @solr_server.solr_query(q, 'id,person_as_written_tesim')
            resp['response']['docs'].map do |pobj|
                pobj['person_as_written_tesim'].each do |p|
                    addressee_labels << p.squish unless p.blank?
                end
            end

            addressee_labels.uniq
        end

        # Ingest::TnaPersonHelper.create_tna_sender
        def self.create_tna_sender(
                document_id,
                senders)
            sender_ids = []

            senders.each do |sender|
                unless sender.strip.blank?
                    tna_sender = TnaSender.new

                    tna_sender.rdftype = tna_sender.add_rdf_types
                    tna_sender.person_as_written = [sender] unless sender.blank?
                    tna_sender.document_id = document_id unless document_id.blank?

                    tna_sender.save
                    sender_ids << tna_sender.id
                end
            end

            sender_ids
        end

        # get tna sender object id array from an array of sender names
        def self.s_get_tna_sender_ids(document_id, senders)
            return nil if senders.blank?

            sender_ids = []
            senders.each do |sender|
                q = 'has_model_ssim:TnaSender AND person_as_written_tesim:"' + sender.downcase + '"'
                q+= ' senderFor_ssim:' + document_id unless document_id.blank?
                resp = @solr_server.solr_query(q, 'id')
                resp['response']['docs'].map do |pobj|
                    sender_ids << pobj['id']
                end
            end
            sender_ids
        end

        # pry(main)> Ingest::TnaPersonHelper.s_get_linked_sender_as_written_labels(d.id)
        def self.s_get_linked_sender_as_written_labels(document_id)
            return nil if document_id.blank?

            sender_labels = []

            q = 'has_model_ssim:TnaSender AND senderFor_ssim:' + document_id
            resp = @solr_server.solr_query(q, 'id,person_as_written_tesim')
            resp['response']['docs'].map do |pobj|
                pobj['person_as_written_tesim'].each do |p|
                    sender_labels << p.squish unless p.blank?
                end
            end

            sender_labels.uniq
        end

        # Ingest::TnaPersonHelper.create_tna_person
        def self.create_tna_person(
                document_id,
                persons)
            person_ids = []

            persons.each do |person|
                unless person.strip.blank?
                    tna_person = TnaPerson.new

                    tna_person.rdftype = tna_person.add_rdf_types
                    tna_person.person_as_written = [person] unless person.blank?
                    tna_person.document_id = document_id unless document_id.blank?

                    tna_person.save
                    person_ids << tna_person.id
                end
            end

            person_ids
        end

        # get tna person object id array from an array of persons' name
        def self.s_get_tna_person_ids(document_id, persons)
            return nil if persons.blank?

            person_ids = []
            persons.each do |person|
                unless person.blank?
                    q = 'has_model_ssim:TnaPerson AND person_as_written_tesim:"' + person.downcase + '"'
                    q+= ' personFor_ssim:' + document_id unless document_id.blank?
                    resp = @solr_server.solr_query(q, 'id')
                    resp['response']['docs'].map do |pobj|
                        person_ids << pobj['id']
                    end
                end
            end
            person_ids
        end

        # pry(main)> Ingest::TnaPersonHelper.s_get_linked_person_as_written_labels(d.id)
        def self.s_get_linked_person_as_written_labels(document_id)
            return nil if document_id.blank?

            person_labels = []

            q = 'has_model_ssim:TnaPerson AND personFor_ssim:' + document_id
            resp = @solr_server.solr_query(q, 'id,person_as_written_tesim')
            resp['response']['docs'].map do |pobj|
                pobj['person_as_written_tesim'].each do |p|
                    person_labels << p.squish unless p.blank?
                end
            end

            person_labels.uniq
        end
    end
end