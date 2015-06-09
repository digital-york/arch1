class LanguageTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'languages'
  end

end