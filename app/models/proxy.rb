class Proxy < ActiveFedora::Base
  include AssignId, RdfType,Iana

  belongs_to :register, predicate: ::RDF::Vocab::ORE.proxyIn
  # in practice this is a 1:1 relationship
  has_and_belongs_to_many :folios, predicate: ::RDF::Vocab::ORE.proxyFor

  # iana next
  # iana prev

  def add_rdf_types
    ['http://www.openarchives.org/ore/terms/Proxy']
  end

end