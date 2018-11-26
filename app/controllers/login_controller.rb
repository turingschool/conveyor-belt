class LoginController < ApplicationController
  skip_before_action :authenticate!

  def show
  end
end
