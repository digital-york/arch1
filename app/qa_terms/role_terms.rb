class RoleTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'roles'
  end

end
