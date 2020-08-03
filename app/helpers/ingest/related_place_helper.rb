module Ingest
    module RelatedPlaceHelper
        # Ingest::RelatedPlaceHelper.create_related_place
        def self.create_related_place(place_as_written,
                                      place_name_authority,
                                      place_roles,
                                      place_types,
                                      place_notes)
            rp = RelatedPlace.new

            rp.rdftype          = rp.add_rdf_types
            rp.place_as_written = [place_as_written] unless place_as_written.blank?       # string
            rp.place_same_as    = place_name_authority unless place_name_authority.blank? # reference
            rp.place_role       = place_roles unless place_roles.blank?                   # reference
            rp.place_type       = place_types unless place_types.blank?                   # reference
            rp.place_note       = place_notes unless place_notes.blank?                   # string

            rp.save

            rp
        end
    end
end