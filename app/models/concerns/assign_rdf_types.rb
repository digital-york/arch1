module AssignRdfTypes
  extend ActiveSupport::Concern

  def add_rdf_types
    # omitting related person/group as this is different
    case self.class.name
      when 'Concept'
        ['http://www.w3.org/2004/02/skos/core#Concept', 'http://pcdm.org/models#Object']
      when 'ConceptScheme'
        ['http://www.w3.org/2004/02/skos/core#ConceptScheme', 'http://pcdm.org/models#Object']
      when 'OrderedCollection'
        ['http://pcdm.org/models#OrderedCollection', 'http://www.openarchives.org/ore/terms/Aggregation', 'http://pcdm.org/models#Collection']
      when 'ContainedFile'
        ['http://pcdm.org/models#hasFile']
      when 'Image'
        ['http://www.w3.org/ns/oa#Annotation', 'http://pcdm.org/models#Object', 'http://purl.org/vra/Image']
      when 'Register'
        ['http://dlib.york.ac.uk/ontologies/borthwick-registers#Register', 'http://pcdm.org/models#Object', 'http://www.shared-canvas.org/ns/OrderedCollection']
      when 'Folio'
        ['http://dlib.york.ac.uk/ontologies/borthwick-registers#Folio',
         'http://pcdm.org/models#Object',
         'http://www.shared-canvas.org/ns/Canvas',
         'http://purl.org/vra/Work']
      when 'Entry'
        ['http://dlib.york.ac.uk/ontologies/borthwick-registers#Entry', 'http://www.shared-canvas.org/ns/Zone', 'http://pcdm.org/models#Object']
      when 'EntryDate'
        ['http://dlib.york.ac.uk/ontologies/borthwick-registers#EntryDate']
      when 'SingleDate'
        ['http://dlib.york.ac.uk/ontologies/borthwick-registers#SingleDate']
      when 'RelatedPlace'
        ['http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedPlace', 'http://schema.org/Place']
      when 'Person'
        ['http://schema.org/Person', 'http://vocab.getty.edu/ontology#PersonConcept', 'http://pcdm.org/models#Object']
      when 'Place'
        ['http://schema.org/Place', 'http://pcdm.org/models#Object']
      when 'Group'
        ['https://schema.org/Organization', 'http://vocab.getty.edu/ontology#GroupConcept', 'http://pcdm.org/models#Object']
      else
        ['http://pcdm.org/models#Object']
    end
  end
end