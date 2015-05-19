class RelatedPlace < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :place_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#place_as_written'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :place_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#place_type'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :place_same_as, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#place_same_as'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :place_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#place_note'), multiple: true do |index|
    index.as :stored_searchable
  end

end
