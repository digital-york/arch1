class SingleDateTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'single_dates'
  end

end