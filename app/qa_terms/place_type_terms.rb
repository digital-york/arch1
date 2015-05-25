class PlaceTypeTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'place-types'
  end

end
