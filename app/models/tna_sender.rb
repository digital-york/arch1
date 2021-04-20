class TnaSender < ActiveFedora::Base
  include RdfType
  include AssignId

  belongs_to :document, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#addresseeFor')

  def add_rdf_types_p
    ['http://dlib.york.ac.uk/ontologies/tna#Sender', 'http://xmlns.com/foaf/0.1/Person', 'http://dlib.york.ac.uk/ontologies/tna#All']
  end

  def add_rdf_types_g
    ['http://dlib.york.ac.uk/ontologies/tna#Sender', 'http://xmlns.com/foaf/0.1/Group', 'http://dlib.york.ac.uk/ontologies/tna#All']
  end

  property :person_same_as, predicate: ::RDF::URI.new('http://www.w3.org/2002/07/owl#sameAs'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#asWritten'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_group, predicate: ::RDF::URI.new('http://schema.org/person_group'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_gender, predicate: ::RDF::URI.new('http://schema.org/gender'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_role, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#role'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_descriptor, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#descriptor'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_descriptor_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#descriptorAsWritten'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_related_place, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#hasRelatedPlace'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_related_person, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#hasRelatedPerson'), multiple: true do |index|
    index.as :stored_searchable
  end
end
