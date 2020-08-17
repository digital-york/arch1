# frozen_string_literal: true

class Place < ActiveFedora::Base
  include AssignRdfTypes
  include Generic
  include RdfsSeealso
  include DCTerms
  include MadsRelauth
  include SkosLabels
  include SameAs
  include AssignId
  include RdfType

  belongs_to :concept_scheme, predicate: ::RDF::Vocab::SKOS.inScheme

  # eg. NCARules name.
  property :place_name, predicate: ::RDF::URI.new('http://www.geonames.org/ontology#name'), multiple: false do |index|
    index.as :stored_searchable
  end

  # eg. NCARules civil parish.
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

  property :note, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/borthwick-registers#note'), multiple: true do |index|
    index.as :stored_searchable
  end
end
