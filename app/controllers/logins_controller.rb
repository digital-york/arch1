class LoginsController < ApplicationController

# LOGIN
  def login
    @login = Login.new
  end

  def create
    puts params.inspect
    @login = Login.new(login_params)
    puts @login
    if params[:username] == 'test' && params[:password] == 'test'
      puts 'here!'
      redirect_to :controller => 'entry', :action => 'login'
    else
      @error = 'incorrect_login'
      redirect_to :action => 'login'
    end
  end

end