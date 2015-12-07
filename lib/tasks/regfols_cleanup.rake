namespace :regfols_cleanup do

  task a: :environment do
    path = Rails.root + 'lib/assets/'

    fol = Folio.find("jd472w527")
    puts fol.id
    fol.images.each_with_index do |i, index|
      if index == 0
        f = File.open(path + "new_regs_and_fols/xmltmp/856337.xml")
        @doc = Nokogiri::XML(f)
        f.close
        i.file_path = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
      else
        i.destroy.eradicate
      end
    end
    fol.save

    r = Register.find("6w924b86j")
    fol = delete_create_folio(220,"Abp Reg 32 p.94A Paper",r)
    create_image("856338",fol)

  end

  task b: :environment do
    path = Rails.root + 'lib/assets/'

    fol = Folio.find("zs25x8606")
    puts fol.id
    fol.images.each_with_index do |i, index|
      if index == 0
        f = File.open(path + "new_regs_and_fols/xmltmp/856339.xml")
        @doc = Nokogiri::XML(f)
        f.close
        i.file_path = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
      else
        i.destroy.eradicate
      end
    end
    fol.save

    r = Register.find("6w924b86j")
    fol = delete_create_folio(222,"Abp Reg 32 p.94B",r)
    create_image("856340",fol)

    fol = delete_create_folio(223,"Abp Reg 32 p.94B",r)
    create_image("856341",fol)

    fol = delete_create_folio(224,"Abp Reg 32 p.94B",r)
    create_image("856342",fol)

    fol = delete_create_folio(225,"Abp Reg 32 p.94B",r)
    create_image("856343",fol)

    fol = delete_create_folio(226,"Abp Reg 32 p.94B",r)
    create_image("856344",fol)

    fol = delete_create_folio(227,"Abp Reg 32 p.94B",r)
    create_image("856345",fol)

  end

  task c: :environment do
    r = Register.find("6w924b86j")
    delete_folio(18,r)
  end


  def create_image(pid,fol)
    path = Rails.root + 'lib/assets/'
    image = Image.new
    image.rdftype = image.add_rdf_types
    f = File.open(path + "new_regs_and_fols/xmltmp/#{pid}.xml")
    @doc = Nokogiri::XML(f)
    f.close
    image.file_path = @doc.css('datastreamProfile dsLocation').text.sub('http://dlib.york.ac.uk/', '/usr/digilib-webdocs/')
    image.id = image.create_container_id(fol.id)
    puts "Creating image #{image.id} for Folio #{fol.preflabel}"
    image.preflabel = "Image"
    image.motivated_by = 'http://www.shared-canvas.org/ns/painting'
    image.folio = fol
    fol.images += [image]
    fol.save
  end

  def delete_create_folio(num,title,reg)
    puts reg.id
    reg.ordered_folio_proxies.delete_at(num)
    fol = Folio.new
    reg.ordered_folio_proxies.insert_target_at(num,fol)
    reg.save
    fol.rdftype = fol.add_rdf_types
    fol.preflabel = title
    reg.save
    puts "#{fol.id} folio created"
    fol
  end

  def delete_folio(num,reg)
    puts reg.ordered_folio_proxies.length
    reg.ordered_folio_proxies.delete_at(num)
    puts reg.ordered_folio_proxies.length
    reg.save
  end

end
