class SubjectsController < ApplicationController

def index

  puts "INDEX"

  @subject_list = SubjectTerms.new('subauthority').all
  #puts @subject_list

end

def new

end

def show
  puts "SHOW"
end

end