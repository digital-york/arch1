namespace :regfols do
  desc "TODO"
  require 'csv'
  task reg_order: :environment do

    arr = CSV.read(Rails.root + 'lib/assets/lists/collections.csv')
    regs = CSV.read(Rails.root + 'lib/assets/lists/registers.csv')

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

        regs.each do | r |
          if r[0].start_with? 'Abp Reg'
            register = Register.create
            register.rdftype = register.add_rdf_types
            register.reg_id = r[1]
            register.date = r[2]
            register.preflabel = r[3]
            o.ordered_register_proxies.append_target register
            o.registers += [register]
          elsif r[0].start_with? 'Abp Inst AB'
            register = Register.create
            register.rdftype = register.add_rdf_types
            register.reg_id = r[1]
            register.date = r[2]
            register.preflabel = r[3]
            o.ordered_register_proxies.append_target register
            o.registers += [register]
          end
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

    # grab thesis app code for constructing the prelabel
    csv.group_by { |row| row[''] }.values.each do |group|
      group.each do |pair|
        begin
          @title = ''
          @title_hash = Hash.new
          begin
            case pair[0].downcase
              when 'image'
                unless pair[1].nil?
                  @title_hash['image'] = pair[1][0..-6].gsub!('_', ' ').gsub(' 000',' ').gsub(' 00',' ').gsub(' 0',' ') #this makes an assumption about the max number
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
                    @title_hash['rv'] =  ' (recto)'
                  elsif pair[1] == 'v'
                    @title_hash['rv'] = ' (verso)'
                  end
                end
              when 'notes'
                unless pair[1].nil?
                  # use as title if there is no folio number
                  @title_hash['notes'] =  ' ' + pair[1].to_s
                end
              when 'uv'
                unless pair[1].nil?
                  @title_hash['uv'] = ' (UV)'
                end
              when 'parent'
                # prefer file to selection
                unless pair[1].nil?
                  @parent = pair[1].to_s

                end
              when 'worktype'
                unless pair[1].nil?
                  @file_output.work.worktypeset.worktype = pair[1].to_s
                end
              when 'pid'
                unless pair[1].nil?
                  @pid = pair[1]
                end
            end
          rescue

          end
          if title_hash['rv'].nil?
            unless title_hash['folio'].nil?
              title_hash['folio'].gsub! ' f.',' p.'
            end
          end
          title = "#{@title_hash['image']}#{@title_hash['part']}#{@title_hash['folio']}#{@title_hash['rv']}#{@title_hash['notes']}#{@title_hash['uv']}"
          title.gsub '  ', ' '

        rescue

        end
      end

    end




  end



end
