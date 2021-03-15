# Place description class, mainly for sorting place names
module Report
    class PlaceDesc
        attr_accessor :place_id, :place_label, :place_name_tesim, :country_code, :parent_adm1_tesim, :parent_adm2_tesim, :parent_adm3_tesim, :parent_adm4_tesim

        def initialize(place_id,
                       place_label,
                       place_name_tesim,
                       country_code,
                       parent_adm1_tesim,
                       parent_adm2_tesim,
                       parent_adm3_tesim,
                       parent_adm4_tesim)
            @place_id = place_id
            @place_label = place_label
            @place_name_tesim = place_name_tesim
            @country_code = country_code
            @parent_adm1_tesim = parent_adm1_tesim
            @parent_adm2_tesim = parent_adm2_tesim
            @parent_adm3_tesim = parent_adm3_tesim
            @parent_adm4_tesim = parent_adm4_tesim
        end

        def <=>(other)
            if @parent_adm1_tesim != other.parent_adm1_tesim
                if @parent_adm1_tesim.blank?
                    return -1
                elsif other.parent_adm1_tesim.blank?
                    return 1
                else
                    return @parent_adm1_tesim <=> other.parent_adm1_tesim
                end
            elsif @parent_adm2_tesim != other.parent_adm2_tesim
                if @parent_adm2_tesim.blank?
                    return -1
                elsif other.parent_adm2_tesim.blank?
                    return 1
                else
                    return @parent_adm2_tesim <=> other.parent_adm2_tesim
                end
            elsif @parent_adm3_tesim != other.parent_adm3_tesim
                if @parent_adm3_tesim.blank?
                    return -1
                elsif other.parent_adm3_tesim.blank?
                    return 1
                else
                    return @parent_adm3_tesim <=> other.parent_adm3_tesim
                end
            elsif @parent_adm4_tesim != other.parent_adm4_tesim
                if @parent_adm4_tesim.blank?
                    return -1
                elsif other.parent_adm4_tesim.blank?
                    return 1
                else
                    return @parent_adm4_tesim <=> other.parent_adm4_tesim
                end
            else
                return @place_name_tesim <=> other.place_name_tesim
            end
        end
    end
end