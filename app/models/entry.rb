class Entry < ActiveFedora::Base

  property :register, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#register'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#folio'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio_face, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#folioFace'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :access_provided_by, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#access_provided_by'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :entry_no, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#entryNo'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :entry_part, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#entryPart'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :is_blank, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#isBlank'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :format, predicate: ::RDF::URI.new('http://purl.org/dc/terms/format'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :language, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#language'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :editorial_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#editorial_note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :marginal_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#marginal_note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :is_referenced_by, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#is_referenced_by'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :subject, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#subject'), multiple: true do |index|
    index.as :stored_searchable
  end

  has_many :related_people, :dependent => :destroy
  has_many :related_places, :dependent => :destroy
  has_many :entry_dates, :dependent => :destroy

  accepts_nested_attributes_for :related_people, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :related_places, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :entry_dates, :allow_destroy => true, :reject_if => :all_blank

end
