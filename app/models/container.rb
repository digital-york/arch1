class Container < ActiveFedora::Base
  include DirectContainer,AssignId

  #a ldp:DirectContainer

  def assign_id
    if @id_path.nil?
      'ctr'
    else
      @id_path + 'ctr'
    end
  end

  property :rdftype, predicate: ::RDF::RDFV.type, multiple: true

end
