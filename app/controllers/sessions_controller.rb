class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_login(params[:session][:login])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_to root_url
    else
      flash.now[:error] = 'Invalid login/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
  end

end
