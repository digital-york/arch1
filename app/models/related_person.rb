class RelatedPerson < ActiveFedora::Base

  include AssignId

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :person_same_as, predicate: ::RDF::URI.new('http://www.w3.org/2002/07/owl#sameAs'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#asWritten'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_gender, predicate: ::RDF::URI.new('http://schema.org/gender'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_role, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#role'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_descriptor, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#descriptor'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_related_place, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#isRelatedPlace'), multiple: true do |index|
    index.as :stored_searchable
  end

  has_many :related_places, :dependent => :destroy

  accepts_nested_attributes_for :related_places, :allow_destroy => true, :reject_if => :all_blank

 end
