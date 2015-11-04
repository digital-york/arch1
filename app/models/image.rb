require 'active_fedora/noid'

# This is a VRA image, NOT a VRA work
# TODO model how to deal with different types of image, including alternative versions and different file types
# TODO model for use with RDFSource and NonRDFSource (and understand how AF does that)
# For Mellon, we'll be using RDFSource, with a link to the image file in F3

class Image < ActiveFedora::Base
  include DCTerms,RdfType,SkosLabels,AssignId

  belongs_to :folio, predicate: ::RDF::URI.new('http://www.w3.org/ns/oa#hasTarget')
  directly_contains :files, has_member_relation: ::RDF::URI.new("http://pcdm.org/models#hasFile"), class_name: 'ContainedFile'

  def add_rdf_types
    ['http://www.w3.org/ns/oa#Annotation','http://pcdm.org/models#Object','http://purl.org/vra/Image']
  end

  # VALUE: http://www.shared-canvas.org/ns/painting
  property :motivated_by, predicate: ::RDF::Vocab::OA.motivatedBy, multiple: false do |index|
    index.as :stored_searchable
  end

  property :file, predicate: ::RDF::URI.new('http://pcdm.org/models#hasFile'), multiple: false do |index|
    index.as :stored_searchable
  end
end