require 'active_fedora/noid'

class Folio < ActiveFedora::Base

  include DCTerms,RdfType,AssignId,Generic,SkosLabels

  belongs_to :register, predicate: ::RDF::DC.isPartOf
  has_many :proxies, :dependent => :destroy
  has_many :entries, :dependent => :destroy
  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :entry, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :proxy, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :image, :allow_destroy => true, :reject_if => :all_blank

  # Adding a lot of relationships (eg. hasMember) with has_and_belongs_to_many causes an error (solr query too large);
  # use has_many and a property instead;
  # or a reciprocal belongs_to (like isPartOf)
  # also won't delete
  # has_and_belongs_to_many :images, predicate: ::RDF::URI.new('http://pcdm.org/models#hasFile')

  def add_rdf_types
    ['http://dlib.york.ac.uk/ontologies/borthwick-registers#Folio',
     'http://pcdm.org/models#Object',
     'http://www.shared-canvas.org/ns/Canvas',
     'http://purl.org/vra/Work']
  end

  property :folio_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioType'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio_no, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioNo'), multiple: false do |index|
    index.as :stored_searchable, :sortable
  end

  property :folio_face, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioFace'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :blank, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#isBlank'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :missing, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#isMissing'), multiple: false do |index|
    index.as :stored_searchable
  end

end
