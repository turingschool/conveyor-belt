class DashboardController < ApplicationController
  def index
    @facade = DashboardFacade.new(current_user)
  end
end
