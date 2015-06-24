class SubjectsController < ApplicationController

def index

  @subject_list = SubjectTerms.new('subauthority').all

end

def new

end

def show

end

end