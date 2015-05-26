class StatusTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'statuses'
  end
end
