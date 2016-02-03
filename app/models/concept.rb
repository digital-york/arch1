class Concept < ActiveFedora::Base

  include RdfType,Generic,SameAs,SkosLabels,DCTerms,AssignId,AssignRdfTypes

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  # Use only for Broader, Narrower will be added by default
  #has_and_belongs_to_many :broader, class_name: 'Concept', predicate: ::RDF::SKOS.broader, inverse_of: :narrower
  #has_and_belongs_to_many :narrower, class_name: 'Concept', predicate: ::RDF::SKOS.narrower, inverse_of: :broader

  property :definition, predicate: ::RDF::SKOS.definition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :see_also, predicate: ::RDF::SKOS.related, multiple: true do |index|
    index.as :stored_searchable
  end

  # change this to has and belongs to many as doesn't save properly in latest version of AF
#=begin
  property :broader, predicate: ::RDF::SKOS.broader, multiple: true do |index|
    index.as :stored_searchable
  end

  property :narrower, predicate: ::RDF::SKOS.narrower, multiple: true do |index|
    index.as :stored_searchable
  end
#=end

  # there is more skos we could add ...

end
