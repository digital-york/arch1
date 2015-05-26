class QualTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'qualifications'
  end

end
