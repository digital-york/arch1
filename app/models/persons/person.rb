class Person < ActiveFedora::Base

  property :title, predicate: ::RDF::DC.title, multiple: false do |index|
    index.as :stored_searchable
  end

  #http://xmlns.com/foaf/0.1/Person
  #http://schema.org/Person
  property :rdftype, predicate: ::RDF::RDFV.type, multiple: true do |index|
    index.as :stored_searchable
  end

  property :relauth, predicate: ::RDF::Vocab::MADS.hasRelatedAuthority, multiple: true do |index|
    index.as :stored_searchable
  end

  has_many :auths
  has_many :variants
end