class NameAsWritten < ActiveFedora::Base

  belongs_to :person, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :name_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#name_as_written'), multiple: false do |index|
    index.as :stored_searchable
  end
end
