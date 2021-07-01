class PlaceOfDating < ActiveFedora::Base

  include AssignId,RdfType,AssignRdfTypes

  belongs_to :document, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tnw#placeOfDatingFor')

  # This is a reference field, stores Place authority id
  property :place_same_as, predicate: ::RDF::URI.new('http://www.w3.org/2002/07/owl#sameAs'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#asWritten'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :place_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#placeType'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :place_role, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#role'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :place_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: true do |index|
    index.as :stored_searchable
  end

end