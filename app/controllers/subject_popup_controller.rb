class SubjectPopupController < ApplicationController

  before_filter :session_timed_out

  def index
    @subject_list = SubjectTerms.new('subauthority').all_top_level_subject_terms
  end

end