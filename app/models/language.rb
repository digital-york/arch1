class Language < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :language, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#language'), multiple: false do |index|
    index.as :stored_searchable
  end
end
