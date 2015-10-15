class AdminsController < ApplicationController

  before_filter :session_timed_out_small

  def index

  end

end