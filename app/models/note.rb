class Note < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#note'), multiple: false do |index|
    index.as :stored_searchable
  end
end
