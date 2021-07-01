class Series < ActiveFedora::Base
  include AssignRdfTypes
  include SkosLabels
  include Generic
  include AssignId
  include RdfType
  include DCTerms

  belongs_to :department, predicate: ::RDF::Vocab::DC.isPartOf
  has_many :documents # , :dependent => :destroy
  has_many :images, dependent: :destroy
  # accepts_nested_attributes_for :entry, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :image, allow_destroy: true, reject_if: :all_blank
  directly_contains :images, has_member_relation: ::RDF::URI.new('http://pcdm.org/models#hasMember'), class_name: 'Image'
end
