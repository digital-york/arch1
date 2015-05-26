class CurrencyTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'currencies'
  end

end
