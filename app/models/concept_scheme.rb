class ConceptScheme < ActiveFedora::Base
  include RdfType,DCTerms,AssignId,SkosLabels,AssignRdfTypes

  has_many :concepts, :dependent => :destroy
  has_many :persons #, :dependent => :destroy
  has_many :places #, :dependent => :destroy
  accepts_nested_attributes_for :concept, :allow_destroy => true, :reject_if => :all_blank
  #accepts_nested_attributes_for :person, :allow_destroy => true, :reject_if => :all_blank
  #accepts_nested_attributes_for :place, :allow_destroy => true, :reject_if => :all_blank

  # DIRECT CONTAINERS ARE TOO SLOW IF CREATING A LOT OF CONTAINED RESOURCES
  #directly_contains :concepts, has_member_relation: ::RDF::URI.new("http://pcdm.org/models#hasMember"), class_name: 'Concept'
  #directly_contains :persons, has_member_relation: ::RDF::URI.new("http://pcdm.org/models#hasMember"), class_name: 'Person'
  #directly_contains :places, has_member_relation: ::RDF::URI.new("http://pcdm.org/models#hasMember"), class_name: 'Place'

  # BASIC CONTAINERS ARE AN OPTION HERE BUT HAVE NOT BEEN TESTED
  #contains :persons, class_name: 'Person'
  #contains :places, class_name: 'Place'
  #contains :concepts, class_name: 'Concept'

  # optional, use for nested subject headings schemes
  property :topconcept, predicate: ::RDF::SKOS.hasTopConcept, multiple: true do |index|
    index.as :stored_searchable
  end

  #etc.

end
