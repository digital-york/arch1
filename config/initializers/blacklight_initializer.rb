# A secret token used to encrypt user_id's in the Bookmarks#export callback URL
# functionality, for example in Refworks export of Bookmarks. In Rails 4, Blacklight
# will use the application's secret key base instead.
#

# Commented out because it says above that Rails 4 uses the SECRET_KEY_BASE instead
#Blacklight.secret_key =  ENV["SECRET_KEY_BLACKLIGHT"]
