class Place < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  has_many :place_as_writtens, :dependent => :destroy
  has_many :place_additional_types, :dependent => :destroy
  has_many :place_notes, :dependent => :destroy

  accepts_nested_attributes_for :place_as_writtens, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :place_additional_types, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :place_notes, :allow_destroy => true, :reject_if => :all_blank

  property :place_authority, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/#place_authority'), multiple: false do |index|
    index.as :stored_searchable
  end
end
