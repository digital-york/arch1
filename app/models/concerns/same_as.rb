module SameAs
  extend ActiveSupport::Concern

  included do
    property :sameas, predicate: ::RDF::OWL.sameAs, multiple: true do |index|
      index.as :stored_searchable
    end
  end

end