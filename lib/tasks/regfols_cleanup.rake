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


  end

  task e: :environment do
    r = Register.find('s7526d74c')

    r.ordered_folio_proxies.append_target Folio.find("sf268649s")
    r.ordered_folio_proxies.append_target Folio.find("np193b36b")
    r.ordered_folio_proxies.append_target Folio.find("ms35t9936")
    r.ordered_folio_proxies.append_target Folio.find("kw52j9675")
    r.ordered_folio_proxies.append_target Folio.find("st74cr714")
    r.ordered_folio_proxies.append_target Folio.find("dj52w6133")
    r.ordered_folio_proxies.append_target Folio.find("ws859h04r")
    r.ordered_folio_proxies.append_target Folio.find("b8515p88p")
    r.ordered_folio_proxies.append_target Folio.find("4f16c416k")
    r.ordered_folio_proxies.append_target Folio.find("dr26xz81m")
    r.ordered_folio_proxies.append_target Folio.find("9w0324469")
    r.ordered_folio_proxies.append_target Folio.find("8p58pf22f")
    r.ordered_folio_proxies.append_target Folio.find("t148fj484")
    r.ordered_folio_proxies.append_target Folio.find("gt54kp407")
    r.ordered_folio_proxies.append_target Folio.find("ff3656776")
    r.ordered_folio_proxies.append_target Folio.find("wd375x89v")
    r.ordered_folio_proxies.append_target Folio.find("mg74qn657")
    r.ordered_folio_proxies.append_target Folio.find("ns0647384")
    r.ordered_folio_proxies.append_target Folio.find("dj52w614c")
    r.ordered_folio_proxies.append_target Folio.find("c247dt504")
    r.ordered_folio_proxies.append_target Folio.find("fj2363519")
    r.ordered_folio_proxies.append_target Folio.find("4b29b742z")
    r.ordered_folio_proxies.append_target Folio.find("pz50gx560")
    r.ordered_folio_proxies.append_target Folio.find("1831cm31n")
    r.ordered_folio_proxies.append_target Folio.find("m039k642v")
    r.ordered_folio_proxies.append_target Folio.find("r494vm54v")
    r.ordered_folio_proxies.append_target Folio.find("9593tw88n")
    r.ordered_folio_proxies.append_target Folio.find("d217qq72t")
    r.ordered_folio_proxies.append_target Folio.find("6969z240w")
    r.ordered_folio_proxies.append_target Folio.find("g158bj64r")
    r.ordered_folio_proxies.append_target Folio.find("mg74qn66h")
    r.ordered_folio_proxies.append_target Folio.find("vh53ww87j")
    r.ordered_folio_proxies.append_target Folio.find("bk128c38g")
    r.ordered_folio_proxies.append_target Folio.find("6108vc769")
    r.ordered_folio_proxies.append_target Folio.find("0z708x670")
    r.ordered_folio_proxies.append_target Folio.find("6682x539m")
    r.ordered_folio_proxies.append_target Folio.find("nc580p18m")
    r.ordered_folio_proxies.append_target Folio.find("w3763825p")
    r.ordered_folio_proxies.append_target Folio.find("xg94hr090")
    r.ordered_folio_proxies.append_target Folio.find("v692t7818")
    r.ordered_folio_proxies.append_target Folio.find("tx31qk190")
    r.ordered_folio_proxies.append_target Folio.find("4m90dw79x")
    r.ordered_folio_proxies.append_target Folio.find("r207tq95w")
    r.ordered_folio_proxies.append_target Folio.find("2n49t3101")
    r.ordered_folio_proxies.append_target Folio.find("pg15bg380")
    r.ordered_folio_proxies.append_target Folio.find("9w032448v")
    r.ordered_folio_proxies.append_target Folio.find("xk81jm94t")
    r.ordered_folio_proxies.append_target Folio.find("fj236352k")
    r.ordered_folio_proxies.append_target Folio.find("9z9031368")
    r.ordered_folio_proxies.append_target Folio.find("cf95jc78t")
    r.ordered_folio_proxies.append_target Folio.find("6h440t846")
    r.ordered_folio_proxies.append_target Folio.find("fb494979h")
    r.ordered_folio_proxies.append_target Folio.find("4b29b7437")
    r.ordered_folio_proxies.append_target Folio.find("5425kb965")
    r.ordered_folio_proxies.append_target Folio.find("pg15bg398")
    r.ordered_folio_proxies.append_target Folio.find("hd76s1380")
    r.ordered_folio_proxies.append_target Folio.find("8s45qb514")
    r.ordered_folio_proxies.append_target Folio.find("8w32r716s")
    r.ordered_folio_proxies.append_target Folio.find("jq085m32z")
    r.ordered_folio_proxies.append_target Folio.find("pn89d8080")
    r.ordered_folio_proxies.append_target Folio.find("v405sb64d")
    r.ordered_folio_proxies.append_target Folio.find("736665815")
    r.ordered_folio_proxies.append_target Folio.find("6682x540c")
    r.ordered_folio_proxies.append_target Folio.find("zk51vj05s")
    r.ordered_folio_proxies.append_target Folio.find("3f462675w")
    r.ordered_folio_proxies.append_target Folio.find("jw827d161")
    r.ordered_folio_proxies.append_target Folio.find("js956h06j")
    r.ordered_folio_proxies.append_target Folio.find("h128ng20j")
    r.ordered_folio_proxies.append_target Folio.find("2b88qd518")
    r.ordered_folio_proxies.append_target Folio.find("tt44pp28q")
    r.ordered_folio_proxies.append_target Folio.find("bv73c201s")
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
