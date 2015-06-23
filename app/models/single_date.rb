class SingleDate < ActiveFedora::Base

  include AssignId

  belongs_to :entry_date, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :date, predicate: ::RDF::URI.new('http://schema.org/date'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_certainty, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#certainty'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#dateType'), multiple: false do |index|
    index.as :stored_searchable
  end

end
