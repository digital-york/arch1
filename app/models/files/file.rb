class File < ActiveFedora::Base
  include Identifier,RdfType,FormerId

  belongs_to :image

  # pcdm:File

  # what do we want to say about the file
  # [datastream] label
  # former filename

end
