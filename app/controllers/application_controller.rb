class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller
  #include Blacklight::Controller

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions. 

  #layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # Note: py changed this from :exception to null_session 17/04/2015
  protect_from_forgery with: :null_session

  # Include concerns
  include RemoveEmptyFields
  include RegisterFolio
  include AuthorityList
  include Solr
end
