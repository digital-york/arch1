class RelatedPlace < ActiveFedora::Base

  include AssignId,RdfType

  belongs_to :entry, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#relatedPlaceFor')
  has_and_belongs_to_many :related_person_group, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#relatedPlaceFor')

  def add_rdf_types
    ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedPlace','http://schema.org/Place']
  end

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