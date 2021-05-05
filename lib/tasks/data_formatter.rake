require 'logger'
require 'json'

namespace :data_formatter do

    desc "format TNA spredsheet"
    # bundle exec rake data_formatter:tna[/home/frank/dlib/nw_data/tna_c81.xlsx,/home/frank/dlib/nw_data/tna_c81_new.xlsx]
    task :tna, [:src_file, :tgt_file] => [:environment] do |t, args|
        src_file = args[:src_file]
        tgt_file = args[:tgt_file]
        Ingest::ExcelHelper.normalize_tna_spreadsheet(src_file, tgt_file)
    end
end
