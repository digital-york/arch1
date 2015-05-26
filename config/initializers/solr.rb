#Load the solr config as SOLR, access like this SOLR[Rails.env]['url']
SOLR = YAML.load_file("#{Rails.root.to_s}/config/solr.yml")