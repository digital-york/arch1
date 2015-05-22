require 'active_fedora/noid'

class Register < ActiveFedora::Base
  include Identifier,RdfType,AssignId,Title

  #belongs_to
  has_many :folios

  #reg:Register
  #pcdm:Object

  property :regref, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#registerReference'), multiple: false do |index|
    index.as :stored_searchable
  end

end
