class Concept < ActiveFedora::Base

  include RdfType,Generic,AssignId,SameAs,SkosLabels,DCTerms,SkosLabels

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  # RDFTYPES
  def add_rdf_types
    ['http://www.w3.org/2004/02/skos/core#Concept']
  end
  # http://fedora.info/definitions/v4/indexing#Indexable

  property :definition, predicate: ::RDF::SKOS.definition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :broader, predicate: ::RDF::SKOS.broader, multiple: true do |index|
    index.as :stored_searchable
  end

  property :narrower, predicate: ::RDF::SKOS.narrower, multiple: true do |index|
    index.as :stored_searchable
  end

  # there is more skos we could add ...

end
