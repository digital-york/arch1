module RdfType
  extend ActiveSupport::Concern

  # what doesn't work is the addition of the mixin type when using this; necessary for ldp:DirectContainer

  included do
    property :rdftype, predicate: ::RDF::RDFV.type, multiple: true do |index|
      index.as :stored_searchable
    end
  end

end