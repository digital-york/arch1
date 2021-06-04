class DocumentDate < ActiveFedora::Base

  include AssignId,RdfType,AssignRdfTypes

  belongs_to :document, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#documentDateFor')
  has_many :single_dates, :dependent => :destroy
  accepts_nested_attributes_for :single_dates, :allow_destroy => true, :reject_if => :all_blank

  property :date_role, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#role'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#note'), multiple: false do |index|
    index.as :stored_searchable
  end

end