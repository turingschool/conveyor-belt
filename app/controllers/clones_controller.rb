class ClonesController < ApplicationController
  skip_before_action :authenticate!

  def new
    @project = Project.find_by(hash_id: params[:project_id])
    @clone = @project.clones.new
    four_oh_four unless @project
  end

  def create
    project = Project.find_by(hash_id: params[:project_hash_id])
    clone = project.clones.create(clone_params)
    ProjectBoardClonerWorker.perform_later(project, clone)

    redirect_to root_path, alert: "Thanks for your submission! Make sure your project cards are in the same order as the board located here: #{project.board_url}"
  end

  private

  def clone_params
    params.require(:clone).permit(:students, :owner, :repo_name)
  end
end
