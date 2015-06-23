require 'active_fedora/noid'

class Folio < ActiveFedora::Base

  include DCTerms,RdfType,AssignId,Pcdm,Generic

  belongs_to :register, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  has_many :entries, :dependent => :destroy
  accepts_nested_attributes_for :entries, :allow_destroy => true, :reject_if => :all_blank

  # ADDING A LOT OF RELATIONSHIPS LIKE THIS CAUSES PROBLEMS SO USING has_many for entries, with a pcdm has_member property instead
  # The reciprocal isPartOf relationship seems better
  has_and_belongs_to_many :images, predicate: ::RDF::URI.new('http://pcdm.org/models#hasFile')

  def add_rdf_types
    ['http://dlib.york.ac.uk/ontologies/borthwick-registers#Folio',
     'http://pcdm.org/models#Object',
     'http://www.shared-canvas.org/ns/Canvas',
     'http://purl.org/vra/Work']
  end

  property :folio_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioType'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio_no, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioNumber'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :folio_face, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioFace'), multiple: false do |index|
    index.as :stored_searchable
  end

end
