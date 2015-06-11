class PlaceTypeTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'place_types'
  end

end
