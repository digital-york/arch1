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

  property :language, predicate: ::RDF::URI.new('http://purl.org/dc/terms/language'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :subject, predicate: ::RDF::URI.new('http://purl.org/dc/terms/subject'), multiple: true do |index|
    index.as :stored_searchable
  end


  has_many :document_dates, :dependent => :destroy
  accepts_nested_attributes_for :document_dates, :allow_destroy => true, :reject_if => :all_blank


  has_many :tna_addressees, :dependent => :destroy
  accepts_nested_attributes_for :tna_addressees, :allow_destroy => true, :reject_if => :all_blank

  has_many :tna_senders, :dependent => :destroy
  accepts_nested_attributes_for :tna_senders, :allow_destroy => true, :reject_if => :all_blank

  has_many :tna_persons, :dependent => :destroy
  accepts_nested_attributes_for :tna_persons, :allow_destroy => true, :reject_if => :all_blank

  has_many :place_of_datings, :dependent => :destroy
  accepts_nested_attributes_for :place_of_datings, :allow_destroy => true, :reject_if => :all_blank

  has_many :tna_places, :dependent => :destroy
  accepts_nested_attributes_for :tna_places, :allow_destroy => true, :reject_if => :all_blank

end