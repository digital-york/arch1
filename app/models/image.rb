require 'active_fedora/noid'

# This is a VRA image, NOT a VRA work
# Need to model for use with RDFSource and NonRDFSource (and understand how AF does that)
# For Mellon, we'll be using RDFSource, with a link to the image file in F3

class Image < ActiveFedora::Base
  include DCTerms,RdfType,AssignId

  belongs_to :folio, predicate: ::RDF::URI.new('http://www.w3.org/ns/oa#hasTarget')

  # VALUE: http://www.shared-canvas.org/ns/painting
  property :motivated_by, predicate: ::RDF::Vocab::OA.motivatedBy, multiple: false do |index|
    index.as :stored_searchable
  end

  property :file, predicate: ::RDF::URI.new('http://pcdm.org/models#hasFile'), multiple: false do |index|
    index.as :stored_searchable
  end

  def add_rdf_types
    ['http://www.w3.org/ns/oa#Annotation','http://pcdm.org/models#File','http://purl.org/vra/Image']
  end

end