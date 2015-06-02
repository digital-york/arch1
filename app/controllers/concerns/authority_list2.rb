module AuthorityList2

  # Get authority lists
  def get_authority_lists
    read_auth = ReadAuth2.new
    @read_language = read_auth.lookup('languages')
    @read_date_type = read_auth.lookup('date-types')
    @read_folio_type = read_auth.lookup('folio-types')
    @read_folio_face = read_auth.lookup('folio-face-types')
    @read_format = read_auth.lookup('formats')
    @read_role = read_auth.lookup('roles')
    @read_qualification = read_auth.lookup('qualifications')
    @read_date_certainty = read_auth.lookup('date-certainty')
    @read_date_type2 = read_auth.lookup('date-types2')
  end

end