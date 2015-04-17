class Occupation < ActiveFedora::Base

  belongs_to :person, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :occupation_name, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#occupation'), multiple: false do |index|
    index.as :stored_searchable
  end
end
