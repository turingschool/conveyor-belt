class DashboardFacade
  def initialize(user)
    @user = user
  end

  def projects
    @projects ||= user.projects
  end

  def project
    Project.new
  end

  private
    attr_reader :user
end
