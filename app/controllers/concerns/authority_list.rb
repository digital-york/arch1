module AuthorityList

  # Get authority lists
  def get_authority_lists
    read_auth = ReadAuth.new
    @read_language = read_auth.lookup('languages')
    @read_date_type = read_auth.lookup('date-types')
    @read_folio_type = read_auth.lookup('folios')
    @read_folio_face = read_auth.lookup('folio-faces')
    @read_format = read_auth.lookup('formats')
    @read_role = read_auth.lookup('roles')
    @read_qualification = read_auth.lookup('qualifications')
    @read_statuses = read_auth.lookup('statuses')
    @read_place_types = read_auth.lookup('place-types')
  end

end