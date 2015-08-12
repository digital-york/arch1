module AuthorityList

  # Get authority lists
  def set_authority_lists

    # Local lists
    read_auth = ReadAuth.new
    @gender_list = read_auth.lookup('genders').collect { |l| [l["label"]] }

    # Fedora lists
    @language_list = LanguageTerms.new('subauthority').all
    @format_list = FormatTerms.new('subauthority').all
    @role_list = PersonRoleTerms.new('subauthority').all
    @descriptor_list = DescriptorTerms.new('subauthority').all
    @place_role_list = PlaceRoleTerms.new('subauthority').all
    @place_type_list = PlaceTypeTerms.new('subauthority').all
    @date_certainty_list = CertaintyTerms.new('subauthority').all
    @single_date_list = DateTypeTerms.new('subauthority').all
    #@single_date_list = SingleDateTerms.new('subauthority').all
    @place_role_list = PlaceRoleTerms.new('subauthority').all
    @date_role_list = DateRoleTerms.new('subauthority').all
    @entry_type_list = EntryTypeTerms.new('subauthority').all

  end

end