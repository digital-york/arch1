class OrderedCollection < ActiveFedora::Base
  include AssignId,RdfType,DCTerms,SkosLabels,Iana

  has_many :registers # do not destroy
  has_many :proxies, :dependent => :destroy
  accepts_nested_attributes_for :proxies, :allow_destroy => true, :reject_if => :all_blank # ???

  def add_rdf_types
    ['http://pcdm.org/models#OrderedCollection','http://www.openarchives.org/ore/terms/Aggregation']
  end

  # use for collections in the context of archives
  property :coll_id, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#reference'), multiple: false do |index|
    index.as :stored_searchable, :sortable
  end

end
