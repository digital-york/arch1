module AuthorityList

  # Get authority lists
  def get_authority_lists

    # Local lists
    read_auth = ReadAuth.new
    #@language_list = read_auth.lookup('languages').collect { |l| [l["label"]] }
    #@format_list = read_auth.lookup('formats').collect { |l| [l["label"]] }
    @gender_list = read_auth.lookup('genders').collect { |l| [l["label"]] }
    #@date_type_list = read_auth.lookup('date-types').collect { |l| [l["label"]] }

    # Fedora lists
    @role_list = RoleTerms.new('subauthority').all
    @qualification_list = QualTerms.new('subauthority').all
    @status_list = StatusTerms.new('subauthority').all
    @place_type_list = PlaceTypeTerms.new('subauthority').all
    @date_type_list = DateTypeTerms.new('subauthority').all
    @date_certainty_list = CertaintyTerms.new('subauthority').all
    @language_list = LanguageTerms.new('subauthority').all
    @format_list = FormatTerms.new('subauthority').all
    @date_type_single_list = SingleDateTypeTerms.new('subauthority').all

    puts
    puts "----------"
    puts "1"
    puts @format_list
    puts "2"
    puts @date_type_list
    puts "3"
    puts @date_type_single_list
    puts "4"
  end

end