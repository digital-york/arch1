class EntryTypeTerms < Terms
  include Qa::Authorities::WebServiceBase

  def terms_list
    'entry_types'
  end

end