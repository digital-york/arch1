# File description class for file report rake task
module Report
    class MissingEntryReportDesc
        attr_accessor :register_label, :folio_label, :entry_id, :create_date, :modify_date

        def initialize(register_label,
                       folio_label,
                       entry_id,
                       create_date,
                       modify_date)
            @register_label = register_label
            @folio_label = folio_label
            @entry_id = entry_id
            @create_date = create_date
            @modify_date = modify_date
        end

        def <=>(other)
            if @register_label != other.register_label
                return @register_label.gsub('Abp Reg ','').to_i <=> other.register_label.gsub('Abp Reg ','').to_i
            elsif @folio_label != other.folio_label
                return (@folio_label.to_i <=> other.folio_label.to_i)
            elsif @entry_id != other.entry_id
                return @entry_id.to_i <=> other.entry_id.to_i
            elsif @create_date != other.create_date
                return -(@create_date <=> other.create_date)
            else
                return @modify_date <=> other.modify_date
            end
        end
    end
end