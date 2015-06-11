class DateRoleTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'date_roles'
  end

end
