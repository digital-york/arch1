class ImageZoomLargeController < ApplicationController

  require 'net/http'

  layout 'image_zoom_large'

  before_filter :session_timed_out_small

  def index

  end

end
