class PlaceType < ActiveFedora::Base

  belongs_to :place, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :additional_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/place#additional_type'), multiple: true do |index|
    index.as :stored_searchable
  end
end
