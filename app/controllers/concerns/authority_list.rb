module AuthorityList

  # Get authority lists
  def get_authority_lists
    read_auth = ReadAuth.new
    @read_language = read_auth.lookup('language')
    @read_date_type = read_auth.lookup('date-type')
    @read_folio_type = read_auth.lookup('folio-type')
    @read_folio_face = read_auth.lookup('folio-face-type')
    @read_format = read_auth.lookup('format')
  end

end