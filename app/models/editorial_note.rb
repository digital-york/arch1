class EditorialNote < ActiveFedora::Base

  #belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  #property :editorial_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#editorial_note'), multiple: false do |index|
   # index.as :stored_searchable
  #end
end
