class ApplicationController < ActionController::Base
  before_action :authenticate!

  protect_from_forgery with: :exception

  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate!
    four_oh_four unless current_user
  end

  def four_oh_four
    raise ActionController::RoutingError.new('Not Found')
  end

  def previous_page
    session[:previous_page]
  end

  def redirect_back_or_to(path, message = {})
    redirect_to (previous_page || path), message
  end
end
