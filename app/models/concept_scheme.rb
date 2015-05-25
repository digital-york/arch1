class ConceptScheme < ActiveFedora::Base
  include RdfType,DCTerms,AssignId

  has_many :concepts
  belongs_to :collection, predicate: ::RDF::URI.new('http://fedora.info/definitions/v4/repository#hasParent')

  # skos:ConceptScheme
  #http://fedora.info/definitions/v4/indexing#Indexable

  # optional, use for nested subject headings schemes
  property :topconcept, predicate: ::RDF::SKOS.hasTopConcept, multiple: true do |index|
    index.as :stored_searchable
  end

  #etc.

end
