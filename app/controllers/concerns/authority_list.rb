module AuthorityList

  include Terms

  # Get authority lists
  def set_authority_lists

    # Local lists
    # Note: these lists use the yml files in config/authorities but we decided to use the hard-coded lists below because
    # there are only a few terms in each
    #@gender_list = Qa::Authorities::Local::FileBasedAuthority.new('genders').all.collect { |l| [l["label"]] }
    #@date_certainty_list = Qa::Authorities::Local::FileBasedAuthority.new('certainty').all.collect { |l| [l["label"]] }
    #@single_date_list = Qa::Authorities::Local::FileBasedAuthority.new('date_types').all.collect { |l| [l["label"]] }

    # Hard-coded lists
    @gender_list = [['female'], ['male'], ['unknown']]
    @date_certainty_list = [["certain"], ["uncertain"], ["inferred"], ["approximate"]]
    @single_date_list = [["start"], ["end"], ["single"]]

    # Lists from solr
    @language_list = LanguageTerms.new('subauthority').all
    @format_list = FormatTerms.new('subauthority').all
    @role_list = PersonRoleTerms.new('subauthority').all
    @descriptor_list = DescriptorTerms.new('subauthority').all
    @place_role_list = PlaceRoleTerms.new('subauthority').all
    @place_type_list = PlaceTypeTerms.new('subauthority').all
    @place_role_list = PlaceRoleTerms.new('subauthority').all
    @date_role_list = DateRoleTerms.new('subauthority').all
    @entry_type_list = EntryTypeTerms.new('subauthority').all
    @section_type_list = SectionTypeTerms.new('subauthority').all

  end

end