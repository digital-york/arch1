namespace :old_tasks do
  desc "Retrospectively add URLs for deep zoom images"
  require 'csv'
  require 'nokogiri'
  task add_images_retro: :environment do
    require 'rsolr'

    # from dlib solr search for ismemberof, return PID,dc.title

    solr = RSolr.connect :url => 'http://localhost:8983/solr/development'


    path = Rails.root + 'lib/assets/'

    list = ['Abp_Reg_32_images.csv', 'Abp_Reg_31_images.csv']

    list.each do |l|
      puts "processing #{l}"
      @csv = CSV.read(Rails.root + 'lib/assets/new_regs_and_fols/' + l, :headers => true)

      @csv.each do |r|

        title = r[1]

        if r[1].class != String
          puts r[1]
        end

        if r[1].end_with? ' (UV)'
          title = title.gsub(' (UV)', '')
        end
        response = solr.get 'select', :params => {
                                        :q => 'preflabel_tesim:"' + title + '"',
                                        :fl => 'id',
                                        :rows => 10
                                    }


        response["response"]["docs"].each do |doc|

          @fol = Folio.find(doc['id'])

          resp = solr.get 'select', :params => {
                                      :q => 'hasTarget_ssim:"' + doc['id'] + '"',
                                      :fl => 'id',
                                      :rows => 10,
                                      :sort => 'id ASC'
                                  }
          if resp["response"]["numFound"] == 2
            if r[1].end_with? ' (UV)'
              i = Image.find(resp["response"]["docs"][1]["id"])
              f = File.open(path + "new_regs_and_fols/xml/#{r[0].sub('york:', '')}.xml")
              @doc = Nokogiri::XML(f)
              f.close
              i.preflabel = 'Image (UV)'
              i.file_path = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
              i.folio = @fol
              @fol.images << i
              @fol.save
              puts "Adding url to #{i.id}: #{i.preflabel} (#{r[1]})"
            else
              img = Image.find(resp["response"]["docs"][0]["id"])
              f = File.open(path + "new_regs_and_fols/xml/#{r[0].sub('york:', '')}.xml")
              @doc = Nokogiri::XML(f)
              f.close
              img.file_path = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
              img.folio = @fol
              @fol.images << img
              @fol.save
              puts "Adding url to #{img.id}: #{img.preflabel} (#{r[1]})"
            end
          else
            image = Image.find(resp["response"]["docs"][0]["id"])
            f = File.open(path + "new_regs_and_fols/xml/#{r[0].sub('york:', '')}.xml")
            @doc = Nokogiri::XML(f)
            f.close
            image.file_path = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
            image.folio = @fol
            # += [image] didn't work here!
            @fol.images << image
            # we can't save the image, we have to do it via the folio
            @fol.save
            puts "Adding url to #{image.id}: #{image.preflabel} (#{r[1]})"
          end

        end
      end
    end
  end
end