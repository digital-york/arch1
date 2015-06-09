class SingleDateTypeTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'formats'
  end

end