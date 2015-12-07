namespace :regfols do
  desc "TODO"
  require 'csv'
  require 'nokogiri'
  task reg_order: :environment do

    arr = CSV.read(Rails.root + 'lib/assets/new_regs_and_fols/collections.csv')
    regs = CSV.read(Rails.root + 'lib/assets/new_regs_and_fols/registers.csv')

    arr.each do |c|
      begin

        # 0 dc:identifier
        # 1 dc:title
        # 2 dc:dates
        # 3 dc:description

        o = OrderedCollection.create
        o.rdftype = o.add_rdf_types
        o.coll_id = c[0]
        o.preflabel = c[1]
        o.date = c[2]
        unless c[3].nil?
          o.description = c[3]
        end
        puts "Ordered Collection #{o.id}"
        o.save

        regs.each do |r|
          if r[0].start_with? 'Abp Reg'
            register = Register.create
            register.rdftype = register.add_rdf_types
            register.reg_id = r[0]
            register.date = r[2]
            register.preflabel = r[1]
            # isPartOf
            register.ordered_collection = o
            # hasPart
            o.ordered_register_proxies.append_target register
            #o.registers += [register]
          elsif r[0].start_with? 'Abp Inst AB'
            register = Register.create
            register.rdftype = register.add_rdf_types
            register.reg_id = r[0]
            register.date = r[2]
            register.preflabel = r[1]
            o.ordered_register_proxies.append_target register
            #o.registers += [register]
          end
          puts "Register #{register.id}"
          o.save
        end
      rescue
        puts $!
      end
    end
  end

  desc "TODO"
  task fol_order: :environment do

    # get the register by searching solr for the reg_id
    # loop through directory processing each spreadsheet

    # 0 Image
    # 1 folio
    # 2 recto/verso
    # 3	Notes
    # 4 UV
    # 5 pid

    list = ['Abp_Reg_32.csv','Abp_Reg_31.csv']

    list.each do |l|
      puts "processing #{l}"
      @csv = CSV.read(Rails.root + 'lib/assets/new_regs_and_fols/' + l, :headers => true)

      # get the register

      @reg = nil
      @fols = []
      fol_t = nil
      fol_id = nil
      @csv.group_by { |row| row[''] }.values.each do |group|
        group.each_with_index do |i, index|
          begin
            puts "Processing number #{index}"
            build_metadata(i)

            if @reg.nil?
              regs = Register.where(reg_id_tesim:'"'+ @title_hash['image'] + '"')
              regs.each do |t|
                fn = l.gsub('_',' ').gsub('.csv','')
                if t.reg_id == fn
                  @reg = t
                end
              end
              puts "Register is #{@reg.id} #{@title_hash['image']}"
            end

            # is it the same folio and UV
            # we are assuming that the UV image is always second
            if ("#{@title_hash['image']}#{@title_hash['part']}#{@title_hash['folio']}#{@title_hash['rv']}#{@title_hash['notes']}" == fol_t) and
                (@title_hash['uv'] == ' (UV)')
              begin
                fol = Folio.find(fol_id)
              rescue
                puts $!
              end
            end

            if fol.nil?
              fol = Folio.new
              fol.preflabel = @title
            end
            # isPartOf
            fol.register = @reg
            fol.save

            puts "Creating folio #{fol.id} - #{fol.preflabel}"

            image = Image.new
            image.rdftype = image.add_rdf_types

            # use the pid column to make a faraday call for the xml
            # extract the url for the xml (see code later on)

            image.file_path = get_file_path(@title_hash['pid'])
            image.id = image.create_container_id(fol.id)
            puts "Creating image #{image.id} for Folio #{fol.preflabel}"
            image.preflabel = "Image#{@title_hash['uv']}"
            image.motivated_by = 'http://www.shared-canvas.org/ns/painting'
            image.folio = fol
            fol.images += [image]
            fol_t = "#{@title_hash['image']}#{@title_hash['part']}#{@title_hash['folio']}#{@title_hash['rv']}#{@title_hash['notes']}"
            fol_id = fol.id
            fol.save
            @fols += [fol]
          rescue
            puts $!
          end
        end
      end
      # do this part as a one off as it was veeeery slow to do it with each folio
      # hasPart
      puts "Adding order to #{@reg}"
      @fols.each_with_index do |f, index|
        puts "Adding order number #{index}"
        @reg.ordered_folio_proxies.append_target f
      end
      @reg.save
      @reg = nil
      @fols = []
      # do I need this part? I think only if I want proxies that aren't in the order (which I obviously don't)
      # and I get them anyway
      # @reg.folios = @fols
    end
  end

  def build_metadata(row)
    @title = ''
    @title_hash = Hash.new
    row.each do |pair|
      build_metadata_from_pair(pair)
    end
    if @title_hash['rv'].nil?
      unless @title_hash['folio'].nil?
        @title_hash['folio'].gsub! ' f.', ' p.'
      end
    end
    @title = "#{@title_hash['image']}#{@title_hash['part']}#{@title_hash['folio']}#{@title_hash['rv']}#{@title_hash['notes']}#{@title_hash['uv']}"
    @title.gsub '  ', ' '
  end

  def build_metadata_from_pair(pair)
    begin
      case pair[0].downcase
        when 'image'
          unless pair[1].nil?
            @image = pair[1]
            @title_hash['image'] = pair[1][0..-6].gsub!('_', ' ').gsub(' 000', ' ').gsub(' 00', ' ').gsub(' 0', ' ') #this makes an assumption about the max number
            @title += ' '
          end
        when 'part'
          unless pair[1].nil?
            @title_hash['part'] = ' ' + pair[1].to_s
          end
        when 'folio'
          unless pair[1].nil?
            @title_hash['folio'] = ' f.' + pair[1].to_s
          end
        when 'recto/verso'
          unless pair[1].nil?
            if pair[1] == 'r'
              @title_hash['rv'] = ' (recto)'
            elsif pair[1] == 'v'
              @title_hash['rv'] = ' (verso)'
            end
          end
        when 'notes'
          unless pair[1].nil?
            # use as title if there is no folio number
            @title_hash['notes'] = ' ' + pair[1].to_s
          end
        when 'uv'
          unless pair[1].nil?
            @title_hash['uv'] = ' (UV)'
          end
        when 'pid'
          unless pair[1].nil?
            @title_hash['uv'] = ' (UV)'
          end
      end
    rescue
      puts $!
    end
  end

  def get_file_path(pid)
    f = File.open(path + "new_regs_and_fols/xml/#{r[0].sub('york:', '')}.xml")
    @doc = Nokogiri::XML(f)
    f.close
    @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
  end

  desc "Retrospectively add URLs for deep zoom images"
  require 'csv'
  require 'nokogiri'
  task add_images_retro: :environment do
    require 'rsolr'

    # from dlib solr search for ismemberof, return PID,dc.title

    solr = RSolr.connect :url => 'http://localhost:8983/solr/development'


    path = Rails.root + 'lib/assets/'

    list = ['Abp_Reg_32_images.csv','Abp_Reg_31_images.csv']

    list.each do |l|
      puts "processing #{l}"
      @csv = CSV.read(Rails.root + 'lib/assets/new_regs_and_fols/' + l, :headers => true)

      @csv.each do | r |

        title = r[1]

        if r[1].class != String
          puts r[1]
        end

        if r[1].end_with? ' (UV)'
          title = title.gsub(' (UV)','')
        end
        response = solr.get 'select', :params => {
                                        :q => 'preflabel_tesim:"' + title + '"',
                                        :fl => 'id',
                                        :rows=>10
                                    }


        response["response"]["docs"].each do | doc |

          @fol = Folio.find(doc['id'])

          resp = solr.get 'select', :params => {
                                          :q => 'hasTarget_ssim:"' + doc['id'] + '"',
                                          :fl => 'id',
                                          :rows=>10,
                                          :sort=>'id ASC'
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
