class SubjectTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'subject'
  end

end
