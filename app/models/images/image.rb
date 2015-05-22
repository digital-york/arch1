require 'active_fedora/noid'

# equates to vra image, NOT vra work

class Image < ActiveFedora::Base
  include Identifier,RdfType,FormerId,AssignId

  has_many :files

  # oa:Annotation
  # pcdm:Object
  # http://purl.org/vra/Image

  #sc:painting
  property :motivatedby, predicate: ::RDF::Vocab::OA.motivatedBy, multiple: false do |index|
    index.as :stored_searchable
  end

  # switch to pcdm when it's available
  property :hasfile, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#hasFile'), multiple: false do |index|
    index.as :stored_searchable
  end

end
