class Format < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :format, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#format'), multiple: false do |index|
    index.as :stored_searchable
  end
end
