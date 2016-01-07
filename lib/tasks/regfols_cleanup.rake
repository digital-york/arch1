namespace :regfols_cleanup do

  task e12_cleanup: :environment do
    count = 1401
    while count <= 1534 do

      begin
        e = Entry.find(SolrQuery.new.solr_query('former_id_tesim:"Abp Reg 12 Entry ' + count.to_s + '"', 'id', 1)['response']['docs'][0]['id'])
        puts e.former_id
        e.destroy.eradicate
        count = count + 1
      rescue
        puts 'skipping' + "Abp Reg 12 Entry #{count.to_s}"
        count = count + 1
      end
    end

  end

  task add_thumbs: :environment do

    r = Register.find(SolrQuery.new.solr_query('reg_id_tesim:"Abp Reg 5A"', 'id', 1)['response']['docs'][0]['id'])
    r.thumbnail_url = 'http://dlib.york.ac.uk/cgi-bin/iipsrv.fcgi?IIIF=/usr/digilib-webdocs/digilibImages/HOA/current/A/20151209/Abp_Reg_05A_1126.jp2/5000,7500,800,800/200,/0/default.jpg'
    r.save

    r = Register.find(SolrQuery.new.solr_query('reg_id_tesim:"Abp Reg 31"', 'id', 1)['response']['docs'][0]['id'])
    r.thumbnail_url = 'http://dlib.york.ac.uk/cgi-bin/iipsrv.fcgi?IIIF=/usr/digilib-webdocs/digilibImages/HOA/current/A/20151110/Abp_Reg_31_0067.jp2/1000,3000,800,800/200,/0/default.jpg'
    r.save

    r = Register.find(SolrQuery.new.solr_query('reg_id_tesim:"Abp Reg 32"', 'id', 1)['response']['docs'][0]['id'])
    r.thumbnail_url = 'http://dlib.york.ac.uk/cgi-bin/iipsrv.fcgi?IIIF=/usr/digilib-webdocs/digilibImages/HOA/current/A/20151110/Abp_Reg_32_0096.jp2/0,5000,800,800/200,/0/default.jpg'
    r.save

  end

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
    
    reg = Register.find("3f4625513")
    reg.ordered_folio_proxies.delete_at(17)
    reg.save
    reg.ordered_folio_proxies.delete_at(23)
    reg.save
    reg.ordered_folio_proxies.delete_at(334)
    reg.save
    reg.ordered_folio_proxies.delete_at(471)
    reg.save
    reg.ordered_folio_proxies.delete_at(530)
    reg.save
    reg.ordered_folio_proxies.delete_at(541)
    reg.save
  end

  task d: :environment do

    r = Register.find('4x51hk428')

    i = 0
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save
    r.ordered_folio_proxies.delete_at(0)
    i = i + 1
    puts 'saving ... ' + i.to_s
    r.save




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
    reg.ordered_folio_proxies.append_target_at(num,fol)
    reg.save
    fol.rdftype = fol.add_rdf_types
    fol.preflabel = title
    reg.save
    puts "#{fol.id} folio created"
    fol
  end

end
