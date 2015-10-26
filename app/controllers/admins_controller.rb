class AdminsController < ApplicationController

  before_filter :session_timed_out_small

  # Reset concept session variables
  def index
  end

end