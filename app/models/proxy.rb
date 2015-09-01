class Proxy < ActiveFedora::Base
  include AssignId, RdfType,Iana

  belongs_to :register, predicate: ::RDF::Vocab::ORE.proxyIn
  belongs_to :ordered_collection, predicate: ::RDF::Vocab::ORE.proxyIn
  # use when we need a specific predicate on a has_many relationship
  # in practice this is a 1:1 relationship
  has_and_belongs_to_many :folios, predicate: ::RDF::Vocab::ORE.proxyFor
  has_and_belongs_to_many :registers, predicate: ::RDF::Vocab::ORE.proxyFor

  def add_rdf_types
    ['http://www.openarchives.org/ore/terms/Proxy']
  end

end