module Ingest
    class TnaPlaceDesc
        attr_accessor :place_as_written, :place_name, :place_role, :place_type, :county, :country

        def initialize(place_as_written,
                       place_name,
                       place_role,
                       place_type,
                       county,
                       country)
            @place_as_written    = place_as_written
            @place_name = place_name
            @place_role = place_role
            @place_type = place_type
            @county = county
            @country = country
        end
    end
end
