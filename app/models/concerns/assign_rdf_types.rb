module AssignRdfTypes
  extend ActiveSupport::Concern

  def add_rdf_types
    # omitting related person/group as this is different
    case self.class.name
      when 'Concept'
        %w(http://www.w3.org/2004/02/skos/core#Concept http://pcdm.org/models#Object)
      when 'ConceptScheme'
        %w(http://www.w3.org/2004/02/skos/core#ConceptScheme http://pcdm.org/models#Object)
      when 'OrderedCollection'
        %w(http://dlib.york.ac.uk/ontologies/generic#OrderedCollection http://www.openarchives.org/ore/terms/Aggregation http://pcdm.org/models#Collection http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      #when 'ContainedFile'
      #  ['http://pcdm.org/models#File','http://dlib.york.ac.uk/ontologies/borthwick-registers#All']
      when 'Image'
        %w(http://www.w3.org/ns/oa#Annotation http://pcdm.org/models#Object http://purl.org/vra/Image http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      when 'Register'
        %w(http://dlib.york.ac.uk/ontologies/borthwick-registers#Register http://pcdm.org/models#Object http://www.shared-canvas.org/ns/Collection http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      when 'Folio'
        %w(http://dlib.york.ac.uk/ontologies/borthwick-registers#Folio http://pcdm.org/models#Object http://www.shared-canvas.org/ns/Canvas http://purl.org/vra/Work http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      when 'Entry'
        %w(http://dlib.york.ac.uk/ontologies/borthwick-registers#Entry http://www.shared-canvas.org/ns/Zone http://pcdm.org/models#Object http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      when 'EntryDate'
        %w(http://dlib.york.ac.uk/ontologies/borthwick-registers#EntryDate http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      when 'SingleDate'
        %w(http://dlib.york.ac.uk/ontologies/borthwick-registers#SingleDate http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      when 'RelatedPlace'
        %w(http://dlib.york.ac.uk/ontologies/borthwick-registers#RelatedPlace http://schema.org/Place http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
      when 'Person'
        %w(http://schema.org/Person http://vocab.getty.edu/ontology#PersonConcept http://pcdm.org/models#Object)
      when 'Place'
        %w(http://schema.org/Place http://pcdm.org/models#Object)
      when 'Group'
        %w(https://schema.org/Organization http://vocab.getty.edu/ontology#GroupConcept http://pcdm.org/models#Object)
      when 'Department'
        %w(http://dlib.york.ac.uk/ontologies/tna#Department http://pcdm.org/models#Object http://www.shared-canvas.org/ns/Collection http://dlib.york.ac.uk/ontologies/tna#All)
      when 'Series'
        %w(http://dlib.york.ac.uk/ontologies/tna#Series http://pcdm.org/models#Object http://www.shared-canvas.org/ns/Canvas http://purl.org/vra/Work http://dlib.york.ac.uk/ontologies/tna#All)
      when 'Document'
        %w(http://dlib.york.ac.uk/ontologies/tna#Document http://www.shared-canvas.org/ns/Zone http://pcdm.org/models#Object http://dlib.york.ac.uk/ontologies/tna#All)
      when 'PlaceOfDating'
        %w(http://dlib.york.ac.uk/ontologies/tna#PlaceOfDating http://schema.org/Place http://dlib.york.ac.uk/ontologies/tna#All)
      when 'TnaPlace'
        %w(http://dlib.york.ac.uk/ontologies/tna#Place http://schema.org/Place http://dlib.york.ac.uk/ontologies/tna#All)
      when 'TnaAddressee'
        %w(http://dlib.york.ac.uk/ontologies/tna#Addressee http://schema.org/Person http://dlib.york.ac.uk/ontologies/tna#All)
      when 'TnaSender'
        %w(http://dlib.york.ac.uk/ontologies/tna#Sender http://schema.org/Person http://dlib.york.ac.uk/ontologies/tna#All)
      when 'TnaPerson'
        %w(http://dlib.york.ac.uk/ontologies/tna#Person http://schema.org/Person http://dlib.york.ac.uk/ontologies/tna#All)
      when 'DocumentDate'
        %w(http://dlib.york.ac.uk/ontologies/tna#DocumentDate http://dlib.york.ac.uk/ontologies/tna#All)
      else
        %w(http://pcdm.org/models#Object http://dlib.york.ac.uk/ontologies/borthwick-registers#All)
    end
  end
end