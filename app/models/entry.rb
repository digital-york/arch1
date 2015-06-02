class Entry < ActiveFedora::Base

  include AssignId

  property :register, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#register'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :entry_no, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#entryNo'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folio'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :folio_face, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#folioFace'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :access_provided_by, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/accessProvidedBy'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :entry_part, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#entryPart'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :is_blank, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#isBlank'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :format, predicate: ::RDF::URI.new('http://purl.org/dc/terms/format'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :language, predicate: ::RDF::URI.new('http://purl.org/dc/terms/language'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :note, predicate: ::RDF::URI.new('hhttp://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :editorial_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#editorial_note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :marginal_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#marginal_note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :is_referenced_by, predicate: ::RDF::URI.new('http://purl.org/dc/terms/is_referenced_by'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :subject, predicate: ::RDF::URI.new('http://purl.org/dc/terms/subject'), multiple: true do |index|
    index.as :stored_searchable
  end

  has_many :related_people, :dependent => :destroy
  has_many :related_places, :dependent => :destroy
  has_many :entry_dates, :dependent => :destroy

  accepts_nested_attributes_for :related_people, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :related_places, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :entry_dates, :allow_destroy => true, :reject_if => :all_blank

end
