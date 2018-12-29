class ProjectsController < ApplicationController
  before_action :confirm_admin!, except: [:show]

  def show
    @project = current_user.projects.find_by(hash_id: params[:id])
    four_oh_four unless @project
  end

  def create
    @project = current_user.projects.new(project_params)

    if @project.save
      redirect_to project_path(id: @project.hash_id)
    else
      redirect_to dashboard_path
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :project_board_base_url)
  end

  def confirm_admin!
    client = Octokit::Client.new(access_token: current_user.token)
    found_org = client.orgs.find { |org| org.login.in?(approved_orgs) }

    not_an_admin! unless found_org
  end

  def not_an_admin!
    redirect_to root_path, alert: "You are not currently a member of an approved org (#{approved_orgs.join(", ")}). Please request access and try again."
  end

  def approved_orgs
    %w(turingschool)
  end
end
