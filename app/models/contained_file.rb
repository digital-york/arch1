require 'active_fedora/noid'

class ContainedFile < ActiveFedora::File
  include ActiveFedora::WithMetadata,AssignId

  def add_rdf_types
    ['http://pcdm.org/models#hasFile']
  end

  metadata do
    include DCTerms, RdfType, SkosLabels
  end

end
