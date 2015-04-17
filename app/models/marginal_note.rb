class MarginalNote < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :marginal_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#marginal_note'), multiple: false do |index|
    index.as :stored_searchable
  end
end
