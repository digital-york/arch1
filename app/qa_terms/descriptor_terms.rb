class DescriptorTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'descriptors'
  end
end
