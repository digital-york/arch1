module Ingest
    module RelatedPlaceHelper
        # Ingest::RelatedPlaceHelper.create_related_place
        def self.create_related_place(place_as_written,
            place_name_authority,
            place_roles,
            place_types,
            place_notes)
            rp = RelatedPlace.new

            rp.rdftype = rp.add_rdf_types
            rp.place_as_written = [place_as_written] unless place_as_written.blank? # string
            rp.place_same_as = place_name_authority unless place_name_authority.blank? # reference
            rp.place_role = place_roles unless place_roles.blank? # reference
            rp.place_type = place_types unless place_types.blank? # reference
            rp.place_note = place_notes unless place_notes.blank? # string

            rp.save

            rp
        end

        # get related place object id from entry_id and place_as_written
        # pry(main)> Ingest::RelatedPlaceHelper.get_related_place_id('0v838095w','Kirkeham')
        # => "gq67js019"
        def self.get_related_place_id(entry_id, place_as_written)
            related_place_id = ''
            query = 'has_model_ssim:"RelatedPlace" AND relatedPlaceFor_ssim:"' + entry_id + '" AND place_as_written_tesim:"'+place_as_written+'"'
            resp = SolrQuery.new.solr_query(query, 'id')
            resp['response']['docs'].map do |p|
                related_place_id = p['id']
            end
            related_place_id
        end
    end
end