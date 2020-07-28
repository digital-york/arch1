module Ingest
    module RelatedPlaceHelper
        # Ingest::RelatedPlaceHelper.create_related_place
        def self.create_related_place(place_same_as,
                                      place_as_written,
                                      place_roles,
                                      place_types,
                                      place_notes)
            rp = RelatedPlace.new

            rp.rdftype          = rp.add_rdf_types
            rp.place_same_as    = place_same_as      # reference
            rp.place_as_written = place_as_written   # string
            rp.place_role       = place_roles        # reference
            rp.place_type       = place_types        # reference
            rp.place_note       = place_notes        # string???

            rp.save

            rp
        end
    end
end