require 'date'
require 'logger'
require 'csv'

# Check place in Solr
namespace :place_checker do
    log = Logger.new "log/place_checker.log"

    # bundle exec rake place_checker:check
    desc "Check places"
    task check: :environment do
        # rows=2147483647
        place_array = []
        response = SolrQuery.new.solr_query('inScheme_ssim:nc580m66v',
                                            fl="id,preflabel_tesim,countrycode,place_name_tesim,parent_ADM1_tesim,parent_ADM2_tesim,parent_ADM3_tesim,parent_ADM4_tesim,feature_code_tesim",
                                            rows=2147483647)['response']['docs'].map do |r|
            # log.debug("This entry doesn't have summary field: " + r['id'])
            place_id = r["id"]
            country_code = r['countrycode'][0] unless r['countrycode'].blank?
            place_label = r['preflabel_tesim'][0] unless r['preflabel_tesim'].blank?
            place_name_tesim = r['place_name_tesim'][0] unless r['place_name_tesim'].blank?
            parent_adm1_tesim = r['parent_ADM1_tesim'][0] unless r['parent_ADM1_tesim'].blank?
            parent_adm2_tesim = r['parent_ADM2_tesim'][0] unless r['parent_ADM2_tesim'].blank?
            parent_adm3_tesim = r['parent_ADM3_tesim'][0] unless r['parent_ADM3_tesim'].blank?
            parent_adm4_tesim = r['parent_ADM4_tesim'][0] unless r['parent_ADM4_tesim'].blank?
            feature_code_tesim = r['feature_code_tesim'].join(',') unless r['feature_code_tesim'].blank?

            current_place = Report::PlaceDesc.new(
                place_id,
                place_label,
                place_name_tesim,
                country_code,
                parent_adm1_tesim,
                parent_adm2_tesim,
                parent_adm3_tesim,
                parent_adm4_tesim,
                feature_code_tesim
            )
            place_array << current_place
        end
        place_array.sort!
        CSV.open("log/places.csv", "w") do |csv|
            csv << ["ID","country_code","parent_adm1","parent_adm2","parent_adm3","parent_adm4","Label", "Place type"]
            place_array.each do |p|
                csv << [p.place_id,
                        p.country_code,
                        p.parent_adm1_tesim,
                        p.parent_adm2_tesim,
                        p.parent_adm3_tesim,
                        p.parent_adm4_tesim,
                        p.place_label,
                        p.feature_code_tesim
                ]
            end
        end

    end

end
