class LoginsController < ApplicationController

# LOGIN
  def login
    @login = Login.new
  end

  def create
    @login = Login.new(login_params)
    if params[:username] == 'test' && params[:password] == 'test'
      redirect_to :controller => 'entry', :action => 'login'
    else
      @error = 'incorrect_login'
      redirect_to :action => 'login'
    end
  end

end