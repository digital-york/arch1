class Status < ActiveFedora::Base

  belongs_to :person, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :status_name, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#status'), multiple: false do |index|
    index.as :stored_searchable
  end
end
