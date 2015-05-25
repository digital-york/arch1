module DCTerms
  extend ActiveSupport::Concern

  included do
    property :identifier, predicate: ::RDF::DC.identifier, multiple: false do |index|
      index.as :stored_searchable, :sortable
    end
    property :description, predicate: ::RDF::DC.description, multiple: false do |index|
      index.as :stored_searchable
    end
    property :title, predicate: ::RDF::DC.title, multiple: false do |index|
      index.as :stored_searchable, :sortable
    end
  end

end