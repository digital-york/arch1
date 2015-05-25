class FolioTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'folios'
  end

end
