# frozen_string_literal: true

class ImageZoomLargeController < ApplicationController
  require 'net/http'

  layout 'image_zoom_large'

  before_action :session_timed_out_small

  def index; end

  def alt; end
end
