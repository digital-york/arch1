module RdfsSeealso
  extend ActiveSupport::Concern
  
  included do
    property :rdfs_seelso, predicate: ::RDF::RDFS.seeAlso, multiple: true do |index|
      index.as :stored_searchable
    end
  end

end