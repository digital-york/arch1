module Ingest
    module PlaceOfDatingHelper
        # Ingest::PlaceOfDatingHelper.create_place_of_dating
        def self.create_place_of_dating(place_as_written,
            place_name_authority,
            place_roles)
            place_of_dating = PlaceOfDating.new

            place_of_dating.rdftype = place_of_dating.add_rdf_types
            place_of_dating.place_as_written = [place_as_written] unless place_as_written.blank? # string
            place_of_dating.place_same_as = place_name_authority unless place_name_authority.blank? # reference
            place_of_dating.place_role = place_roles unless place_roles.blank? # reference


            place_of_dating.save

            place_of_dating
        end

        # get place_of_dating object id from document_id and place_as_written
        # pry(main)> Ingest::PlaceOfDatingHelper.get_place_of_dating_id('0v838095w','Kirkeham')
        # => "gq67js019"
        def self.get_place_of_dating_id(document_id, place_as_written)
            return '' if document_id.blank? or place_as_written.blank?

            place_of_dating_id = ''
            query = 'has_model_ssim:"PlaceOfDating" AND placeOfDatingFor_ssim:"' + document_id + '" AND place_as_written_tesim:"'+place_as_written+'"'
            resp = SolrQuery.new.solr_query(query, 'id')
            resp['response']['docs'].map do |p|
                place_of_dating_id = p['id']
            end
            place_of_dating_id
        end
    end
end