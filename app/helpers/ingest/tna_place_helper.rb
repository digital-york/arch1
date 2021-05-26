module Ingest
    module TnaPlaceHelper
        # Ingest::TnaPlaceHelper.create_tna_place
        def self.create_tna_place(place_as_written,
            place_name_authority,
            place_roles,
            place_note)

            tna_place = TnaPlace.new

            tna_place.rdftype = tna_place.add_rdf_types
            tna_place.place_as_written = [place_as_written] unless place_as_written.blank? # string
            tna_place.place_same_as = place_name_authority unless place_name_authority.blank? # reference
            tna_place.place_role = place_roles unless place_roles.blank? # reference
            tna_place.place_note = place_note unless place_note.blank?

            tna_place.save

            tna_place
        end
    end
end