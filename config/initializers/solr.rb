#Load the solr config as SOLR, access like this SOLR[Rails.env]['url']
SOLR = YAML.load(ERB.new(IO.read("#{Rails.root.to_s}/config/solr.yml")).result)
