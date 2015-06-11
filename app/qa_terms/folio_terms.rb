class FolioTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'folio_types'
  end

end
