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

            # if it's a UV image don't create a new folio
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
      # firstly get rid of any duplicates
      @fols = @fols.uniq!

      # hasPart
      puts "Adding order to #{@reg}"
      @fols.each_with_index do |f, index|
        puts "Adding order number #{index}"
        @reg.ordered_folio_proxies.append_target f
      end
      @reg.save
      @reg = nil
      @fols = []
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

  task reg_thumbs: :environment do

    # read a list
    r = Register.new

    # Create the contained file
    f = ContainedFile.new
    # create the id (otherwise we'll get a fedora uuid)
    f.id = f.create_id(r.id)

    # add to the Image
    r.associated_files += [f]

    # add content and metadata
    f.content = File.open("/home/geekscruff/Downloads/11891207_10100458809286534_6920419511510170264_n.jpg")
    f.mime_type = 'image/jpeg'
    f.original_name = '11891207_10100458809286534_6920419511510170264_n.jpg'
    f.preflabel = 'Matilda!'
    f.rdftype = f.add_rdf_types

    # Save the register
    # DO NOT SAVE THE ContainedFile - will cause errors

    r.save

  end




  def get_file_path(pid)

    require 'faraday'

    conn = Faraday.new(:url => 'http://dlib.york.ac.uk') do |c|
      c.use Faraday::Request::UrlEncoded # encode request params as "www-form-urlencoded"
      c.use Faraday::Response::Logger # log request & response to STDOUT
      c.use Faraday::Adapter::NetHttp # perform requests with Net::HTTP
    end
    conn.basic_auth(ENV['YODL_ADMIN_USER'], ENV['YODL_ADMIN_PASS'])
    response = conn.get "/fedora/objects/#{pid}/datastreams/JP2&format=xml"
    #f = File.open(path + "new_regs_and_fols/xml/#{r[0].sub('york:', '')}.xml")
    @doc = Nokogiri::XML(response.body)
    #f.close
    @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
  end

end
