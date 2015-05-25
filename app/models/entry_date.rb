class EntryDate < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :date_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#date_as_written'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#date_note'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#date_type'), multiple: false do |index|
    index.as :stored_searchable
  end

end
