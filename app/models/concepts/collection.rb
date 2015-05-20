class Collection < ActiveFedora::Base
  include RdfType,Identifier

  #pcdm:Collection
  #http://fedora.info/definitions/v4/indexing#Indexable optional!

  has_many :conceptschemes
  has_many :concepts

end
