module SkosLabels
  extend ActiveSupport::Concern

  # what doesn't work is the addition of the mixin type when using this; necessary for ldp:DirectContainer

  included do
    property :pref_label, predicate: ::RDF::SKOS.prefLabel, multiple: false do |index|
      index.as :stored_searchable, :sortable
    end

    property :alt_label, predicate: ::RDF::SKOS.altLabel, multiple: true do |index|
      index.as :stored_searchable
    end
  end

end