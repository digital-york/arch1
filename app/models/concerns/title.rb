module Title
  extend ActiveSupport::Concern

  included do
    property :title, predicate: ::RDF::DC.title, multiple: false do |index|
      index.as :stored_searchable
    end
  end

end