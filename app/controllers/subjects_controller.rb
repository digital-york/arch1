class SubjectsController < ApplicationController

def index

  @subject_list = SubjectTerms.new('subauthority').all_top_level_subject_terms

end

def new

end

def show

end

end