class RelatedPerson < ActiveFedora::Base

  include AssignId

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :person_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#asWritten'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_role, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#role'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_qualification, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#qualification'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_status, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#status'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_gender, predicate: ::RDF::URI.new('http://schema.org/gender'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_same_as, predicate: ::RDF::URI.new('http://www.w3.org/2002/07/owl#sameAs'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_related_place, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#isRelatedPlace'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: true do |index|
    index.as :stored_searchable
  end

 end
