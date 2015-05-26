class CertaintyTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'certainty'
  end

end
