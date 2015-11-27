class Group < ActiveFedora::Base

  include RdfType, AssignId, SameAs, SkosLabels, MadsRelauth, RdfsSeealso, DCTerms,Generic,AssignRdfTypes

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  # eg. NCA Rules 4
  property :name, predicate: ::RDF::Vocab::FOAF.name, multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCA Rules 4.4
  property :dates, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/dates'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCA Rules 4.4 use for places and status/function/sphere of activity designation as needed
  property :qualifier, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#qualifier'), multiple: false do |index|
    index.as :stored_searchable
  end

  property :note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: true do |index|
    index.as :stored_searchable
  end

  property :group_type, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#groupType'), multiple: true do |index|
    index.as :stored_searchable
  end

end