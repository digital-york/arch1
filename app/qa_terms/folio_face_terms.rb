class FolioFaceTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'folio_faces'
  end

end
