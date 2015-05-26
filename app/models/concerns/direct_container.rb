module DirectContainer
  extend ActiveSupport::Concern

  # Direct Containers are not indexed

  included do
    property :member_resource, predicate: ::RDF::Vocab::LDP.membershipResource, false: true

    property :is_member_of, predicate: ::RDF::Vocab::LDP.isMemberOfRelation, false: true

    property :has_member, predicate: ::RDF::Vocab::LDP.hasMemberRelation, false: true

  end

end