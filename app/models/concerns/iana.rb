module Iana
  extend ActiveSupport::Concern

  #QUESTION: what to add here, id or 'object'; in latter case we get the full fedora URL rather than the id,
  # this is what we get with other relations

  included do
    property :fst, predicate: ::RDF::Vocab::IANA.first, multiple: false do |index|
      index.as :stored_searchable
    end

    property :lst, predicate: ::RDF::Vocab::IANA.last, multiple: false do |index|
      index.as :stored_searchable
    end

    property :next, predicate: ::RDF::Vocab::IANA.next, multiple: false do |index|
      index.as :stored_searchable
    end

    property :prev, predicate: ::RDF::Vocab::IANA.prev, multiple: false do |index|
      index.as :stored_searchable
    end
  end

end