class SingleDateTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'singledates'
  end

end