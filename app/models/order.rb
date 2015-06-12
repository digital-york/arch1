class Order < ActiveFedora::Base
  include DCTerms

  # NOT USING THIS AT THE MOMENT

  has_many :proxies
  belongs_to :register, predicate: ::RDF::Vocab::ORE.proxyIn

  property :first, predicate: ::RDF::Vocab::IANA.first, multiple: false do |index|
    index.as :stored_searchable
  end

  property :last, predicate: ::RDF::Vocab::IANA.last, multiple: false do |index|
    index.as :stored_searchable
  end

end