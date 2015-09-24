class Place < ActiveFedora::Base

  include RdfType, AssignId, SameAs, SkosLabels, MadsRelauth, DCTerms, RdfsSeealso,Generic

  belongs_to :concept_scheme, predicate: ::RDF::SKOS.inScheme

  def add_rdf_types
    ['http://schema.org/Place']
  end

  # eg. NCARules civil parish
  property :parent_ADM4, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM4'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCARules local administrative unit
  property :parent_ADM3, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM3'), multiple: false do |index|
    index.as :stored_searchable
  end
  # eg. NCARules county/wider administrative unit
  property :parent_ADM2, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM2'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCARules country (England)
  property :parent_ADM1, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentADM1'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. UK
  property :parent_country, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#parentCountry'), multiple: false do |index|
    index.as :stored_searchable
  end

  # use http://unlock.edina.ac.uk/ws/supportedFeatureTypes?&gazetteer=deep&format=json
  property :feature_code, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#featureType'), multiple: true do |index|
    index.as :stored_searchable
  end

end