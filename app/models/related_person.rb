class RelatedPerson < ActiveFedora::Base

  belongs_to :entry, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  property :person_as_written, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_as_written'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_role, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_role'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_qualification, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_qualification'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_gender, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_gender'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_same_as, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_same_as'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :person_related_place, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_related_place'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_place_of_residence, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_place_of_residence'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :person_note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/entry#person_note'), multiple: true do |index|
    index.as :stored_searchable
  end

  #has_many :name_as_writtens, :dependent => :destroy
  #accepts_nested_attributes_for :name_as_writtens, :allow_destroy => true, :reject_if => :all_blank

 end
