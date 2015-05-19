class RelatedPerson < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  has_many :name_as_writtens, :dependent => :destroy
  has_many :role_names, :dependent => :destroy
  has_many :occupations, :dependent => :destroy
  has_many :statuses, :dependent => :destroy
  has_many :qualifications, :dependent => :destroy

  accepts_nested_attributes_for :name_as_writtens, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :role_names, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :occupations, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :statuses, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :qualifications, :allow_destroy => true, :reject_if => :all_blank

  property :note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#note'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :age, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#age'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :gender, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#gender'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :name_authority, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry/person#name_authority'), multiple: false do |index|
    index.as :stored_searchable
  end
end
