class PlaceNote < ActiveFedora::Base

  belongs_to :place, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :place_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/place/#place_note'), multiple: false do |index|
    index.as :stored_searchable
  end
end
