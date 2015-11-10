class Register < ActiveFedora::Base
  include DCTerms,RdfType,AssignId,Iana,Generic,SkosLabels,AssignRdfTypes
  require 'active_fedora/aggregation'

  has_many :folios, :dependent => :destroy
  belongs_to :ordered_collection, predicate: ::RDF::DC.isPartOf
  accepts_nested_attributes_for :folios, :allow_destroy => true, :reject_if => :all_blank
  ordered_aggregation :folios, through: :list_source

  property :reg_id, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#reference'), multiple: false do |index|
    index.as :stored_searchable, :sortable
  end

  property :access_provided_by, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/accessProvidedBy'), multiple: false do |index|
    index.as :stored_searchable
  end

end
