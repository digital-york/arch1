class DateTypeTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'date_types'
  end

end
