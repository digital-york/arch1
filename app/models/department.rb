class Department < ActiveFedora::Base
    include ThumbnailUrl
    include AssignRdfTypes
    include SkosLabels
    include Generic
    include AssignId
    include RdfType
    include DCTerms

    has_many :series, dependent: :destroy
    belongs_to :ordered_collection, predicate: ::RDF::Vocab::DC.isPartOf
    accepts_nested_attributes_for :series, allow_destroy: true, reject_if: :all_blank
    ordered_aggregation :series, through: :list_source
    directly_contains :associated_files, has_member_relation: ::RDF::URI.new('http://pcdm.org/models#hasFile'), class_name: 'ContainedFile'

    property :department_id, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#department_id'), multiple: false do |index|
        index.as :stored_searchable, :sortable
    end

    property :repository, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/tna#department_repository'), multiple: false do |index|
        index.as :stored_searchable, :sortable
    end

    property :access_provided_by, predicate: ::RDF::URI.new('http://data.archiveshub.ac.uk/def/accessProvidedBy'), multiple: false do |index|
        index.as :stored_searchable
    end
end
