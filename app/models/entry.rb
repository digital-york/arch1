class Entry < ActiveFedora::Base

  validates :entry_no, presence: true

  property :register, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#register'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#folio'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio_face, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#folioFace'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :entry_no, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#entryNo'), multiple: false do |index|
    index.as :stored_searchable
  end

  has_many :editorial_notes, :dependent => :destroy
  has_many :formats, :dependent => :destroy
  has_many :marginal_notes, :dependent => :destroy
  has_many :is_referenced_bies, :dependent => :destroy
  has_many :languages, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :entry_dates, :dependent => :destroy
  has_many :people, :dependent => :destroy
  has_many :places, :dependent => :destroy
  has_many :subjects, :dependent => :destroy

  accepts_nested_attributes_for :editorial_notes, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :formats, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :marginal_notes, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :is_referenced_bies, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :languages, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :notes, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :entry_dates, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :people, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :places, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :subjects, :allow_destroy => true, :reject_if => :all_blank

  property :access_provided_by, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#access_provided_by'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :document, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#document'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :document_part, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#document_part'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#folio_type'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio_face_temp, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#folio_face_temp'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :entry_part, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#entry_part'), multiple: false do |index|
    index.as :stored_searchable
  end
end
