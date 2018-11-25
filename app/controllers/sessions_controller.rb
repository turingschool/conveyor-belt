class SessionsController < ApplicationController
  skip_before_action :authenticate!

  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to dashboard_path, notice: "Signed in!"
  end

  def destroy
    session.clear
    redirect_to root_path
  end
end
