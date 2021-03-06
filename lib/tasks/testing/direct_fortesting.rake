namespace :direct_fortesting do

  desc "TODO"

  task man: :environment do
    # Create the object, this automatically creates the direct container
    i = Register.find('2n49t181k')
    i.save

    puts i.id

    # Create the contained file
    f = ContainedFile.create
    # create the id (otherwise we'll get a fedora uuid)
    f.id = "#{i.id}/associated_files/manifest"

    puts f.id

    # add to the Image
    i.associated_files += [f]

    # add content and metadata
    f.content = File.open("/home/geekscruff/Downloads/11891207_10100458809286534_6920419511510170264_n.jpg")
    #f.mime_type = 'image/jpeg'
    f.preflabel = 'IIIF Manifest'
    puts f.rdftype
    puts f.preflabel
    puts 'saving'
    i.save

    i.save

  end

  task file: :environment do

    # Create the object, this automatically creates the direct container
    i = Image.new
    i.save

    puts i.id

    # Create the contained file
    f = ContainedFile.new
    # create the id (otherwise we'll get a fedora uuid)
    f.id = f.create_container_id(i.id)

    # add to the Image
    i.files << f

    # add content and metadata
    f.content = File.open("/home/geekscruff/Downloads/11891207_10100458809286534_6920419511510170264_n.jpg")
    f.mime_type = 'image/jpeg'
    f.preflabel = 'IIIF Manifest'
    f.rdftype = f.add_rdf_types

    # Create the contained file
    f = ContainedFile.new
    # create the id (otherwise we'll get a fedora uuid)
    f.id = f.create_id(i.id)

    # add to the Image
    i.files += [f]

    # add content and metadata
    f.content = 'whatever 2'
    f.preflabel = 'whatever 2'
    f.rdftype = f.add_rdf_types

    # Save the Image object
    # DO NOT SAVE THE ContainedFile - will cause errors

    i.save

  end

  task image: :environment do

    # Create the object, this automatically creates the direct container
    i = Folio.new
    i.save

    puts i.id

    # Create the image
    f = Image.new
    # create the id (otherwise we'll get a fedora uuid)
    f.id = f.create_container_id(i.id)
    f.folio = i

    f.rdftype = f.add_rdf_types
    f.preflabel = 'Hello'

    # add to the folio after we've added the metadata
    i.images += [f]

    # Create the image
    f = Image.new
    # create the id (otherwise we'll get a fedora uuid)
    f.id = f.create_container_id(i.id)
    f.folio = i

    # add content and metadata
    f.preflabel = 'whatever 2'
    f.rdftype = f.add_rdf_types

    # add to the folio after we've added the metadata
    i.images += [f]

    # Save the Folio object
    # DO NOT SAVE THE ContainedFile - will cause errors

    i.save

  end

  task man2: :environment do
    # Create the object, this automatically creates the direct container
    i = Register.find('2n49t181k')
    puts i.id

    # Create the contained file
    #f = ContainedFile.create
    # create the id (otherwise we'll get a fedora uuid)
    #f.id = f.create_container_id(i.id)
    #puts f.id

    # add to the Image
    #i.associated_files += [f]

    # add content and metadata
    i.manifest.content = File.open("/home/geekscruff/Downloads/11891207_10100458809286534_6920419511510170264_n.jpg")
    i.manifest.mime_type = 'image/jpeg'
    i.manifest.preflabel = 'IIIF Manifest'
    puts 'saving'
    i.save
  end


end




