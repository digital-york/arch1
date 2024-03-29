class SingleDate < ActiveFedora::Base

  include AssignId,RdfType,AssignRdfTypes

  belongs_to :entry_date, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#dateFor')
  belongs_to :document_date, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#dateFor')

  property :date, predicate: ::RDF::URI.new('http://schema.org/date'), multiple: false do |index|
    index.as :stored_searchable
  end

  #TODO update form to allow multiple
  property :date_certainty, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#certainty'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :date_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#dateType'), multiple: false do |index|
    index.as :stored_searchable
  end

end