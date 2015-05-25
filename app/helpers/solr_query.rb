require 'rubygems'
require 'rsolr'

class SolrQuery

  CONN = RSolr.connect :url => SOLR[Rails.env]['url']

  def solr_query(q, fl='id', rows=10, sort='', start=0 )
    CONN.get 'select', :params => {
                         :q=>q,
                         :fl=>fl,
                         :start=>start,
                         :rows=>rows,
                          :sort=>sort}
  end
end