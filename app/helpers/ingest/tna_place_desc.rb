module Ingest
    class TnaPlaceDesc
        attr_accessor :place_as_written, :place_name, :place_role, :place_type, :county, :country, :place_note

        def initialize(place_as_written,
                       place_name,
                       place_role,
                       place_type,
                       county,
                       country)
            @place_as_written    = place_as_written
            # add 'Identification uncertain' to place note field if the place name starting with '?'
            if place_name.starts_with? '? '
                @place_name = place_name[2..place_name.length]
                @place_note = 'identification uncertain'
            elsif place_name.starts_with? '?'
                @place_name = place_name[1..place_name.length]
                @place_note = 'identification uncertain'
            else
                @place_name = place_name
            end
            @place_role = place_role
            @place_type = place_type
            @county = county
            @country = country
        end
    end
end
