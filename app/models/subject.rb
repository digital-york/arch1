class Subject < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :subject, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#subject'), multiple: false do |index|
    index.as :stored_searchable
  end
end
