class Person < ActiveFedora::Base

  include RdfType, AssignId, SameAs, SkosLabels, MadsRelauth, RdfsSeealso, DCTerms

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  def add_rdf_types
    ['http://schema.org/Person','http://vocab.getty.edu/ontology#PersonConcept']
  end

  # eg. NCA Rules 2.4
  property :family, predicate: ::RDF::FOAF.familyName, multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCA Rules 2.5C
  property :pre_title, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#preTitle'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCA Rules 2.3
  property :given_name, predicate: ::RDF::FOAF.givenName, multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCA Rules 2.5A
  property :dates, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/dates'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCA Rules 2.5B
  property :post_title, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/title'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCA Rules 2.5D
  property :epithet, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/epithet'), multiple: false do |index|
    index.as :stored_searchable
  end

end