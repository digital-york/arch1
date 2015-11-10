class Concept < ActiveFedora::Base

  include RdfType,Generic,SameAs,SkosLabels,DCTerms,AssignId,AssignRdfTypes

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  property :definition, predicate: ::RDF::SKOS.definition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :see_also, predicate: ::RDF::SKOS.related, multiple: true do |index|
    index.as :stored_searchable
  end

  #this could be a has and belongs to many?
  property :broader, predicate: ::RDF::SKOS.broader, multiple: true do |index|
    index.as :stored_searchable
  end

  property :narrower, predicate: ::RDF::SKOS.narrower, multiple: true do |index|
    index.as :stored_searchable
  end

  # there is more skos we could add ...

end
