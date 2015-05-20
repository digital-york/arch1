require 'active_fedora/noid'

class Concept < ActiveFedora::Base
  include Identifier,RdfType,FormerId,AssignId,SameAs

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  # skos:Concept
  # http://fedora.info/definitions/v4/indexing#Indexable

  property :preflabel, predicate: ::RDF::SKOS.prefLabel, multiple: false do |index|
    index.as :stored_searchable
  end

  property :altlabel, predicate: ::RDF::SKOS.altLabel, multiple: true do |index|
    index.as :stored_searchable
  end

  property :definition, predicate: ::RDF::SKOS.definition, multiple: false do |index|
    index.as :stored_searchable
  end

  property :broader, predicate: ::RDF::SKOS.broader, multiple: true do |index|
    index.as :stored_searchable
  end

  property :narrower, predicate: ::RDF::SKOS.narrower, multiple: true do |index|
    index.as :stored_searchable
  end

  # boolean
  property :istopconcept, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#isTopConcept'), multiple: false do |index|
    index.as :stored_searchable
  end

  # boolean
  property :approved, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#approved'), multiple: false do |index|
    index.as :stored_searchable
  end

  # there is more skos we could add ...

end
