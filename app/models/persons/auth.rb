class Auth < ActiveFedora::Base

  property :title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end

  property :authlabel, predicate: ::RDF::Vocab::MADS.authoritativeLabel, multiple: false do |index|
    index.as :stored_searchable
  end

  #http://www.loc.gov/standards/mads/rdf/v1.html#Authority
  #http://www.loc.gov/standards/mads/rdf/v1.html#PersonalName
  #http://www.w3.org/2009/08/skos-reference/skos.html#Concept
  property :rdftype, predicate: ::RDF::RDFV.type, multiple: true do |index|
    index.as :stored_searchable
  end

  property :hasvariant, predicate: ::RDF::Vocab::MADS.hasVariant, multiple: true do |index|
    index.as :stored_searchable
  end

  belongs_to :person, predicate: ::RDF::Vocab::MADS.identifiesRWO
  has_many :full_name_elements
  has_many :date_name_elements
  has_many :termsofaddress_name_elements
  has_many :occupations

end