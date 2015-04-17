class Qualification < ActiveFedora::Base

  belongs_to :person, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :qualification_name, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#qualification'), multiple: false do |index|
    index.as :stored_searchable
  end
end
