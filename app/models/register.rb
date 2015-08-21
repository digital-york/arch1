class Register < ActiveFedora::Base

  include DCTerms,RdfType,AssignId,Iana,Pcdm,Generic

  has_many :folios, :dependent => :destroy

  accepts_nested_attributes_for :folios, :allow_destroy => true, :reject_if => :all_blank

  property :reg_id, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#reference'), multiple: false do |index|
    index.as :stored_searchable
  end

  # pcdm has_member
  # iana first
  # iana last

  def add_rdf_types
    ['http://dlib.york.ac.uk/ontologies/borthwick-registers#Register','http://pcdm.org/models#Object','http://www.shared-canvas.org/ns/Collection']
  end

end
