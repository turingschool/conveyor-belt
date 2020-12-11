class DashboardFacade
  def initialize(user)
    @user = user
  end

  def projects
    @projects ||= user.projects
    if user.admin?
      @projects = Project.all.order(:project_board_base_url)
    end
  end

  def project
    Project.new
  end

  private
    attr_reader :user
end
