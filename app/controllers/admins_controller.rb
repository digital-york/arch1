# frozen_string_literal: true

class AdminsController < ApplicationController
  before_action :session_timed_out_small

  def index; end
end
