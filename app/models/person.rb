class Person < ActiveFedora::Base
  include RdfType,AssignId,SameAs,RdfsLabel

  has_many :personauths

  def add_rdf_types
    ['http://schema.org/Person']
  end

  property :relauth, predicate: ::RDF::Vocab::MADS.hasRelatedAuthority, multiple: true do |index|
    index.as :stored_searchable
  end

  property :alt_name, predicate: ::RDF::URI.new('http://schema.org/alternativeName'), multiple: true do |index|
    index.as :stored_searchable
  end


end