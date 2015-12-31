module RegisterFolioHelper

  # Get the thumbnail image for the register
  def get_thumb(register)

    thumb = SolrQuery.new.solr_query("id:#{register}", 'thumbnail_url_tesim', 1)['response']['docs'][0]['thumbnail_url_tesim']
    if thumb.nil?
      #return a generic thumbnail
      'register_default.jpg'
    else
      thumb[0]
    end

  end
end