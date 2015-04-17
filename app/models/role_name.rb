class RoleName < ActiveFedora::Base

  belongs_to :person, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :role_name, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#role_name'), multiple: false do |index|
    index.as :stored_searchable
  end
end
