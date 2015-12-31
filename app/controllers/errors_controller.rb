class ErrorsController < ApplicationController

  # Note: not being used at the moment because I was having problems with
  # some error pages just displaying blank on the production server.
  # Therefore I've gone back to using the default error pages for tails in the public folder
  def not_found
    render(:status => 404)
  end

  def unprocessable_entity
    render(:status => 422)
  end

  def internal_server_error
    render(:status => 500)
  end
end