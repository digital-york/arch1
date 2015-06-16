class EntryDate < ActiveFedora::Base

  include AssignId

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :date_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#asWritten'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_role, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#role'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#dateType'), multiple: false do |index|
    index.as :stored_searchable
  end

  has_many :single_dates, :dependent => :destroy

  accepts_nested_attributes_for :single_dates, :allow_destroy => true, :reject_if => :all_blank

end
