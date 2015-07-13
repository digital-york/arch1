class ImageZoomLargeController < ApplicationController

  layout 'image_zoom_large'

  require 'net/http'

  before_filter :session_timed_out

  def index

    remote_server = "http://dlib.york.ac.uk"
    remote_dzi_base_url = '/cgi-bin/iipsrv.fcgi?DeepZoom=/usr/digilib-webdocs/digilibImages/ArchbishopsRegisters/'
    remote_dzi_image_url = 'reg12/JP2/Reg_12_005_Recto.jp2.dzi'

    @dzi_url_str = remote_server + remote_dzi_base_url + remote_dzi_image_url

    # Get the xml from the url and replace the carriage returns, otherwise it doesn't work
    dzi_xml = Net::HTTP.get('dlib.york.ac.uk', remote_dzi_base_url + remote_dzi_image_url)
    dzi_xml = dzi_xml.gsub(/\r/,' ')
    @dzi_xml = dzi_xml.gsub(/\n/,' ')
    @dzi_xml = @dzi_xml.html_safe
  end

  def session_timed_out
    if session[:login] != 'true'
      render 'timed_out', :layout => 'session_timed_out'
    end
  end

end
