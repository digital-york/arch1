module Identifier
  extend ActiveSupport::Concern

  included do
    property :identifier, predicate: ::RDF::DC.identifier, multiple: false do |index|
      index.as :stored_searchable
    end
  end

end