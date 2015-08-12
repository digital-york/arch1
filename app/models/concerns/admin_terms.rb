module AdminTerms
  extend ActiveSupport::Concern

  included do
    # boolean
    property :approved, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#approved'), multiple: false do |index|
      index.as :stored_searchable
    end
    property :rules, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#rules'), multiple: false do |index|
      index.as :stored_searchable
    end
  end

end