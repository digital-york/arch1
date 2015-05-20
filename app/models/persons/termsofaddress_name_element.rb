class TermsofaddressNameElement < ActiveFedora::Base
  include Title,RdfType,Identifier

  property :toa_name_element, predicate: ::RDF::Vocab::MADS.elementValue, multiple: false do |index|
    index.as :stored_searchable
  end

  #http://www.loc.gov/standards/mads/rdf/v1.html#TermsOfAddressNameElement

  belongs_to :auth, predicate: ::RDF::Vocab::MADS.elementList
  belongs_to :variant, predicate: ::RDF::Vocab::MADS.elementList

end