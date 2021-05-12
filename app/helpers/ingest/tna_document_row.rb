module Ingest
    # This class defines all fields loaded from TNA spreadsheet
    class TnaDocumentRow
        attr_reader :repository,
                    :department,
                    :series,
                    :reference,
                    :publication,
                    :summary,
                    :entry_date_note,
                    :note,
                    :document_type,
                    :date_of_document,
                    :place_of_dating,
                    :language,
                    :subject,
                    :addressee,
                    :sender,
                    :person,
                    :place

        attr_writer :repository,
                    :department,
                    :series,
                    :reference,
                    :publication,
                    :summary,
                    :entry_date_note,
                    :note,
                    :document_type,
                    :date_of_document,
                    :place_of_dating,
                    :language,
                    :subject,
                    :addressee,
                    :sender,
                    :person,
                    :place

        def to_s
            repository + ' / ' + department + ' / ' + reference
        end
    end
end
