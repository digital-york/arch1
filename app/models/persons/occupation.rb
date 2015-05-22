class Occupation < ActiveFedora::Base
  include Title,RdfType,Identifier

  property :occupation, predicate: ::RDF::Vocab::MADS.elementValue, multiple: false do |index|
    index.as :stored_searchable
  end

  #http://www.loc.gov/standards/mads/rdf/v1.html#Occupation

  belongs_to :auth, predicate: ::RDF::Vocab::MADS.elementList
  belongs_to :variant, predicate: ::RDF::Vocab::MADS.elementList

end