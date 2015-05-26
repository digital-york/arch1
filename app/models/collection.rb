class Collection < ActiveFedora::Base
  include RdfType,DirectContainer,DCTerms

  #pcdm:Collection
  #http://fedora.info/definitions/v4/indexing#Indexable

  has_many :conceptschemes
  has_many :concepts

end
