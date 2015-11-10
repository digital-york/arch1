namespace :regfols do
  desc "TODO"
  require 'csv'
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

    list = ['Abp_Reg_31.csv','Abp_Reg_32.csv']

    list.each do | l |
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
              @reg = Register.where(reg_id: '"'+ @title_hash['image'] + '"').first
              puts "Register is #{@reg.id}"
            end

            #is it the same folio
            if "#{@title_hash['image']}#{@title_hash['part']}#{@title_hash['folio']}#{@title_hash['rv']}#{@title_hash['notes']}" == fol_t
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
            image.file = 'assets/reg_23-e323da66b28a2b4d178be69812f1a18617e144d66d378644e24684b46783df72.png' # boilerplate to be replaced with some code

            if @title_hash['notes'] && @title_hash['notes'].strip.downcase == 'colour reference image'
              image.preflabel = "#{@title_hash['note']}"
              image.registers += [@reg]
              puts "Creating image colour reference image on register #{image.id}"
              image.save
            else
              image.id = image.create_container_id(fol.id)
              puts "Creating image #{image.id} for Folio #{fol.preflabel}"
              image.preflabel = "Image#{@title_hash['uv']}"
              image.motivated_by = 'http://www.shared-canvas.org/ns/painting'
              image.folio = fol
              fol.images += [image]
            end

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
      puts "Adding order"
      @fols.each_with_index do |f, index|
        puts "Adding order number #{index}"
        @reg.ordered_folio_proxies.append_target f
      end
      # do I need this part? I think only if I want proxies that aren't in the order (which I obviously don't)
      # and I get them anyway
      # @reg.folios = @fols
      @reg.save
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
      end
    rescue
      puts $!
    end
  end

end
