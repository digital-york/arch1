module AuthorityList

  include Terms

  # Get authority lists
  def set_authority_lists

    begin

      # Hard-coded lists
      @gender_list = [['female'], ['male'], ['unknown']]
      @person_group_list = [['person'], ['group']]
      @date_certainty_list = [["certain"], ["uncertain"], ["inferred"], ["approximate"]]
      @single_date_list = [["start"], ["end"], ["single"]]

      # Lists from solr
      @language_list = LanguageTerms.new('subauthority').all
      @format_list = FormatTerms.new('subauthority').all
      @role_list = PersonRoleTerms.new('subauthority').all
      @descriptor_list = DescriptorTerms.new('subauthority').all
      @place_role_list = PlaceRoleTerms.new('subauthority').all
      @place_type_list = PlaceTypeTerms.new('subauthority').all
      @date_role_list = DateRoleTerms.new('subauthority').all
      @entry_type_list = EntryTypeTerms.new('subauthority').all
      @section_type_list = SectionTypeTerms.new('subauthority').all

    rescue => error
      log_error(__method__, __FILE__, error)
      raise
    end

  end

end