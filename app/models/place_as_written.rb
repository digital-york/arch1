class PlaceAsWritten < ActiveFedora::Base

  belongs_to :place, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :place_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/place#place_as_written'), multiple: true do |index|
    index.as :stored_searchable
  end
end
