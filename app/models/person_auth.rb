class PersonAuth < ActiveFedora::Base
  include RdfType,AssignId,SkosLabels

  def add_rdf_types
    ['http://www.loc.gov/standards/mads/rdf/v1.html#Authority',
     'http://www.loc.gov/standards/mads/rdf/v1.html#PersonalName',
     'http://www.w3.org/2009/08/skos-reference/skos.html#Concept']
  end

  belongs_to :person, predicate: ::RDF::Vocab::MADS.identifiesRWO

end