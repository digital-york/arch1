namespace :cleanup do
  desc "TODO"
  task rdftypes: :environment do

    # Ordered Collection
    puts 'Ordered Collection'

    OrderedCollection.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Register
    puts 'Register'
    Register.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Folio
    puts 'Folio'
    Folio.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Image
    puts 'Image'
    Image.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Entry
    puts 'Entry'
    Entry.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # RelatedAgent
    puts 'Rel agent'
    RelatedAgent.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # RelatedPlace
    puts 'Rel place'
    RelatedPlace.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # EntryDate
    puts 'Dates'
    EntryDate.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    #SingleDate

    SingleDate.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end


  end

end
