# TNA document
class Document < ActiveFedora::Base

  include AssignId,Generic,RdfType,AssignRdfTypes

  belongs_to :series, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#series')

  property :repository, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#repository'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :reference, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#reference'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :publication, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#publication'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :summary, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#summary'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :entry_date_note, predicate: ::RDF::URI.new('http://purl.org/dc/terms/language'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :document_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#document-type'), multiple: true do |index|
    index.as :stored_searchable
  end

  # has_many :related_agents, :dependent => :destroy
  # has_many :related_places, :dependent => :destroy
  # has_many :entry_dates, :dependent => :destroy
  #
  # accepts_nested_attributes_for :related_agents, :allow_destroy => true, :reject_if => :all_blank
  # accepts_nested_attributes_for :related_places, :allow_destroy => true, :reject_if => :all_blank
  # accepts_nested_attributes_for :entry_dates, :allow_destroy => true, :reject_if => :all_blank

end