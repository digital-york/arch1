require 'active_fedora/noid'

class Folio < ActiveFedora::Base
  include Identifier,RdfType,FormerId,AssignId

  #belongs_to
  has_many :entries
  has_many :images

  #reg:Folio
  #sc:Canvas
  #pcdm:Object

  property :foliotype, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioType'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :foliono, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioNumber'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folioface, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioFace'), multiple: false do |index|
    index.as :stored_searchable
  end

end
