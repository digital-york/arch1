class SubjectPopupController < ApplicationController

  def index
    @subject_list = SubjectTerms.new('subauthority').all_top_level_subject_terms
  end

end