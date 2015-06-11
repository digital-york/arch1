class PlaceRoleTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'place_roles'
  end

end
