class FullNameElement < ActiveFedora::Base

  property :title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end

  property :name_element, predicate: ::RDF::Vocab::MADS.elementValue, multiple: false do |index|
    index.as :stored_searchable
  end

  #http://www.loc.gov/standards/mads/rdf/v1.html#FullNameElement
  property :rdftype, predicate: ::RDF::RDFV.type, multiple: true do |index|
    index.as :stored_searchable
  end

  belongs_to :auth, predicate: ::RDF::Vocab::MADS.elementList
  belongs_to :variant, predicate: ::RDF::Vocab::MADS.elementList

end