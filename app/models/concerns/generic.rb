module Generic
  extend ActiveSupport::Concern

  included do
    property :former_id, predicate: ::RDF::URI.new('http://dlib.york.ac.uk/ontologies/generic#formerIdentifier'), multiple: true do |index|
      index.as :stored_searchable
    end
  end

end