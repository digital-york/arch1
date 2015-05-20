class Person < ActiveFedora::Base
  include Title,RdfType,Identifier,AssignId

  #http://xmlns.com/foaf/0.1/Person
  #http://schema.org/Person

  property :relauth, predicate: ::RDF::Vocab::MADS.hasRelatedAuthority, multiple: true do |index|
    index.as :stored_searchable
  end

  has_many :auths
  has_many :variants
end