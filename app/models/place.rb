class Place < ActiveFedora::Base
  include RdfType,AssignId,SameAs,SkosLabels,MadsRelauth,DCTerms,AdminTerms,RdfsSeealso

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  def add_rdf_types
    ['http://schema.org/Place']
  end

  # eg. NCARules country (England)
  property :parentADM1, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM1'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCARules county/wider administrative unit
  property :parentADM2, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM2'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCARules local administrative unit
  property :parentADM3, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM3'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCARules civil parish
  property :parentADM4, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM4'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. UK
  property :parentCountry, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentCountry'), multiple: false do |index|
    index.as :stored_searchable
  end

  # use http://unlock.edina.ac.uk/ws/supportedFeatureTypes?&gazetteer=deep&format=json
  property :feature_code, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#featureType'), multiple: true do |index|
    index.as :stored_searchable
  end

  #

end