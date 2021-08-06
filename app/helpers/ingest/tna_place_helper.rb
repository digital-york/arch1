module Ingest
    module TnaPlaceHelper
        # Ingest::TnaPlaceHelper.create_tna_place
        def self.create_tna_place(
            document_id,
            place_as_written,
            place_name_authority_ids,
            place_roles,
            place_note)

            tna_place = TnaPlace.new

            tna_place.rdftype = tna_place.add_rdf_types
            tna_place.place_as_written = [place_as_written] unless place_as_written.blank? # string
            tna_place.place_same_as = place_name_authority_ids[0] unless place_name_authority_ids.blank? or place_name_authority_ids.length()>1 # reference
            tna_place.place_role = place_roles unless place_roles.blank? # reference
            tna_place.place_note = [place_note] unless place_note.blank?
            tna_place.document_id = document_id unless document_id.blank?

            tna_place.save

            tna_place
        end

        # get tna_place object id from document_id, place name authority id and place_as_written
        # pry(main)> Ingest::TnaPlaceHelper.get_tna_place_id('0v838095w','xxx','Kirkeham')
        # => "gq67js019"
        def self.get_tna_place_id(document_id, place_authority_id, place_as_written)
            return '' if document_id.blank?

            tna_place_id = ''
            query = 'has_model_ssim:"TnaPlace" AND tnaPlaceFor_ssim:"' + document_id + '"'
            unless place_as_written.blank?
                query += ' AND place_as_written_tesim:"' + place_as_written + '"'
            end
            unless place_authority_id.blank?
                query += ' AND place_same_as_tesim:"' + place_authority_id + '"'
            end
            resp = SolrQuery.new.solr_query(query, 'id')
            resp['response']['docs'].map do |p|
                tna_place_id = p['id']
            end
            tna_place_id
        end
    end
end