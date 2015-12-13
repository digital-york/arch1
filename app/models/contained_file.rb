require 'active_fedora/noid'

class ContainedFile < ActiveFedora::File
  include ActiveFedora::WithMetadata,AssignId,AssignRdfTypes

  metadata do
    include DCTerms, RdfType, SkosLabels


  end

end
