class Place < ActiveFedora::Base
  include RdfType,AssignId,SameAs,RdfsLabel

  has_many :placeauths

  def add_rdf_types
    ['http://schema.org/Place']
  end

  property :relauth, predicate: ::RDF::Vocab::MADS.hasRelatedAuthority, multiple: true do |index|
    index.as :stored_searchable
  end

end