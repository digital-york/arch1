module Ingest
    module PlaceOfDatingHelper
        # Ingest::PlaceOfDatingHelper.create_place_of_dating
        def self.create_place_of_dating(
            document_id,
            place_as_written,
            place_authority_ids,
            place_roles,
            place_note='')
            place_of_dating = PlaceOfDating.new

            place_of_dating.rdftype = place_of_dating.add_rdf_types
            place_of_dating.place_as_written = [place_as_written] unless place_as_written.blank? # string
            place_of_dating.place_same_as = place_authority_ids[0] unless place_authority_ids.blank? # reference
            place_of_dating.place_role = place_roles unless place_roles.blank? # reference
            place_of_dating.place_note = [place_note] unless place_note.blank?
            place_of_dating.document_id = document_id unless document_id.blank?

            place_of_dating.save

            place_of_dating
        end

        # get place_of_dating object id from document_id and place_as_written
        # pry(main)> Ingest::PlaceOfDatingHelper.get_place_of_dating_id('0v838095w','xxx','Kirkeham')
        # => "gq67js019"
        def self.get_place_of_dating_id(document_id, place_authority_id, place_as_written)
            return '' if document_id.blank?

            place_of_dating_id = ''
            query = 'has_model_ssim:"PlaceOfDating" AND placeOfDatingFor_ssim:"' + document_id + '"'
            unless place_as_written.blank?
                query += ' AND place_as_written_tesim:"' + place_as_written + '"'
            end
            unless place_authority_id.blank?
                query += ' AND place_same_as_tesim:"' + place_authority_id + '"'
            end
            resp = SolrQuery.new.solr_query(query, 'id')
            resp['response']['docs'].map do |p|
                place_of_dating_id = p['id']
                break unless place_of_dating_id.blank?
            end
            place_of_dating_id
        end
    end
end