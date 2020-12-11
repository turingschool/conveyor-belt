module Admin
  class ProjectsController < AdminBaseController
    def show
      @project = project
      four_oh_four unless @project
    end

    def create
      @project = current_user.projects.new(project_params)

      if @project.save
        DashboardCreatorJob.perform_later(@project)
        redirect_to admin_project_path(id: @project.hash_id)
      else
        redirect_to dashboard_path
      end
    end

    private
    def project_params
      params.require(:project).permit(:name, :project_board_base_url)
    end

    def project
      @project ||= Project.find_by(hash_id: params[:id])
    end
  end
end
