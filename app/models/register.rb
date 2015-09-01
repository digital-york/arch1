class Register < ActiveFedora::Base
  include DCTerms,RdfType,AssignId,Iana,Generic,SkosLabels

  has_many :folios, :dependent => :destroy
  has_many :proxies, :dependent => :destroy
  belongs_to :ordered_collection, predicate: ::RDF::DC.isPartOf
  accepts_nested_attributes_for :folios, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :proxies, :allow_destroy => true, :reject_if => :all_blank

  def add_rdf_types
    ['http://dlib.york.ac.uk/ontologies/borthwick-registers#Register','http://pcdm.org/models#Object','http://www.shared-canvas.org/ns/OrderedCollection']
  end

  property :reg_id, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#reference'), multiple: false do |index|
    index.as :stored_searchable, :sortable
  end

  property :access_provided_by, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/accessProvidedBy'), multiple: false do |index|
    index.as :stored_searchable
  end

end
