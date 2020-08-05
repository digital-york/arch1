# frozen_string_literal: true

class Concept < ActiveFedora::Base
  include AssignRdfTypes
  include AssignId
  include DCTerms
  include SkosLabels
  include SameAs
  include Generic
  include RdfType

  belongs_to :concept_scheme, predicate: ::RDF::Vocab::SKOS.inScheme

  # Use only for Broader, Narrower will be added by default
  has_and_belongs_to_many :broader,
                          class_name: 'Concept',
                          predicate: ::RDF::Vocab::SKOS.broader,
                          inverse_of: :narrower
  has_and_belongs_to_many :narrower,
                          class_name: 'Concept',
                          predicate: ::RDF::Vocab::SKOS.narrower,
                          inverse_of: :broader

  property :definition, predicate: ::RDF::Vocab::SKOS.definition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :see_also, predicate: ::RDF::Vocab::SKOS.related, multiple: true do |index|
    index.as :stored_searchable
  end

  # change this to has and belongs to many as doesn't save properly in latest version of AF
  #   property :broader, predicate: ::RDF::SKOS.broader, multiple: true do |index|
  #     index.as :stored_searchable
  #   end
  #
  #   property :narrower, predicate: ::RDF::SKOS.narrower, multiple: true do |index|
  #     index.as :stored_searchable
  #   end

  # there is more skos we could add ...
end
