class Order < ActiveFedora::Base
  include DCTerms

  belongs_to :register, predicate: ::RDF::Vocab::ORE.proxyIn
  has_many :proxies, :dependent => :destroy
  accepts_nested_attributes_for :proxies, :allow_destroy => true, :reject_if => :all_blank

  def add_rdf_types
    ['http://dlib.york.ac.uk/ontologies/dlib_generic#Order']
  end

  property :first, predicate: ::RDF::Vocab::IANA.first, multiple: false do |index|
    index.as :stored_searchable
  end

  property :last, predicate: ::RDF::Vocab::IANA.last, multiple: false do |index|
    index.as :stored_searchable
  end

end