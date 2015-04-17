class EntryDate < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :date_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/date#date_type'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/date#date_as_written'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_span, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/date#date_span'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date_certainty, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/date#date_certainty'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :date, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/date#date'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/date#note'), multiple: false do |index|
    index.as :stored_searchable
  end
end
