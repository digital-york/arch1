namespace :cleanup do
  desc "TODO"
  task rdftypes: :environment do

    # Ordered Collection

    OrderedCollection.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Register

    Register.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Folio

    Folio.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Image

    Image.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # Entry

    Entry.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # RelatedAgent

    RelatedAgent.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # RelatedPlace

    RelatedPlace.all.each do | t |
      t.rdftype += ['http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      t.save
    end

    # EntryDate

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
