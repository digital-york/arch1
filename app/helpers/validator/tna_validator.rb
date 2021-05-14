require 'logger'

module Validator
    # This class validate TNA document
    class TnaValidator

        # validate if all place authorities exist before ingest
        def self.validate_place(tna_document_row)
            log = Logger.new "log/tna_place_validator.log"
            documents_with_missing_place = []

            # check all place_of_dating fields to see if there are any place name haven't been indexed in the Place authority
            unless tna_document_row.place_of_dating.blank?
                place_of_dating_descs = Ingest::ExcelHelper.extract_places_info(tna_document_row.place_of_dating, 'place of dating', '')
                place_of_dating_descs.each_with_index do |place_of_dating_desc, index|
                    place_of_dating_id = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                        place_of_dating_desc.place_name,
                        place_of_dating_desc.county,
                        place_of_dating_desc.country)
                    documents_with_missing_place << "#{tna_document_row.reference} [#{index+1}]" if place_of_dating_id.blank?
                end
            end

            # check all place fields to see if there are any place name haven't been indexed in the Place authority
            unless tna_document_row.place.blank?
                place_descs = Ingest::ExcelHelper.extract_places_info(tna_document_row.place, '', '')
                place_descs.each_with_index do |place_desc, index|
                    place_id = Ingest::AuthorityHelper.s_get_exact_match_place_object_id(
                        place_desc.place_name,
                        place_desc.county,
                        place_desc.country)
                    documents_with_missing_place << "#{tna_document_row.reference} (#{index+1})" if place_id.blank?
                end
            end
            documents_with_missing_place
        end

    end
end