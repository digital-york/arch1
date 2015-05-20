require 'active_fedora/noid'

ActiveFedora::Noid.configure do |config|
  # Specify a different template for your repository's NOID IDs
  # can only use ':' if that namespace is already set in Fedora
  config.template = 'test:.zd'
  config.statefile = 'config/noid-minter-state'
end