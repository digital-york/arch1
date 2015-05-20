class Variant < ActiveFedora::Base
  include Title,RdfType,Identifier

  #http://www.loc.gov/standards/mads/rdf/v1.html#Variant
  #http://www.loc.gov/standards/mads/rdf/v1.html#PersonalName

  property :relauth, predicate: ::RDF::Vocab::MADS.hasRelatedAuthority, multiple: true do |index|
    index.as :stored_searchable
  end

  belongs_to :person, predicate: ::RDF::Vocab::MADS.identifiesRWO
  has_many :full_name_elements
  has_many :date_name_elements
  has_many :termsofaddress_name_elements
  has_many :occupations

end