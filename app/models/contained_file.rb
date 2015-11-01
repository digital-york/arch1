require 'active_fedora/noid'

class ContainedFile < ActiveFedora::File
  include ActiveFedora::WithMetadata

  def add_rdf_types
    ['http://pcdm.org/models#hasFile']
  end

  metadata do
    include DCTerms, RdfType, SkosLabels
  end

  def create_id(path)
    "#{path}/files/#{noid_service.mint}"
  end

  private
  def noid_service
    @noid_service ||= ActiveFedora::Noid::Service.new
  end

end
