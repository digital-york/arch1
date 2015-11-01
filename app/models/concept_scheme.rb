class ConceptScheme < ActiveFedora::Base
  include RdfType,DCTerms,AssignId,SkosLabels

  has_many :concepts, :dependent => :destroy
  has_many :persons, :dependent => :destroy
  has_many :places, :dependent => :destroy
  accepts_nested_attributes_for :concept, :allow_destroy => true, :reject_if => :all_blank
  #accepts_nested_attributes_for :person, :allow_destroy => true, :reject_if => :all_blank
  #accepts_nested_attributes_for :place, :allow_destroy => true, :reject_if => :all_blank

  def add_rdf_types
    ['http://www.w3.org/2004/02/skos/core#ConceptScheme']
  end

  # optional, use for nested subject headings schemes
  property :topconcept, predicate: ::RDF::SKOS.hasTopConcept, multiple: true do |index|
    index.as :stored_searchable
  end

  #etc.

end
