class IsReferencedBy < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :is_referenced_by, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#is_referenced_by'), multiple: false do |index|
    index.as :stored_searchable
  end
end
