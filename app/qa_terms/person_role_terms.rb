class PersonRoleTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'person_roles'
  end

end
