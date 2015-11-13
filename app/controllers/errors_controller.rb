class ErrorsController < ApplicationController

  def not_found
    log_error(exception)
    render(:status => 404)
  end

  def unprocessable_entity
    log_error(exception)
    render(:status => 422)
  end

  def internal_server_error
    log_error(exception)
    render(:status => 500)
  end
end