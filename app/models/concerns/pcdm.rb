module Pcdm
  extend ActiveSupport::Concern

  #QUESTION: what to add here, id or 'object'; in latter case we get the full fedora URL rather than the id,
  # this is what we get with other relations

  included do
    property :has_member, predicate: ::RDF::URI.new('http://pcdm.org/models#hasMember'), multiple: true do |index|
      index.as :stored_searchable
    end
  end

end