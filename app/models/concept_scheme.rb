class ConceptScheme < ActiveFedora::Base
  include RdfType,DCTerms,AssignId

  has_many :concepts

  # RDFTYPES
  def add_rdf_types
    ['http://www.w3.org/2004/02/skos/core#ConceptScheme']
  end
  # http://fedora.info/definitions/v4/indexing#Indexable

  # optional, use for nested subject headings schemes
  property :topconcept, predicate: ::RDF::SKOS.hasTopConcept, multiple: true do |index|
    index.as :stored_searchable
  end

  #etc.

end
