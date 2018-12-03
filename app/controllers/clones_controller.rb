class ClonesController < ApplicationController
  skip_before_action :authenticate!

  def new
    @project = Project.find_by(hash_id: params[:project_id])
    @clone = @project.clones.new
    four_oh_four unless @project
  end

  def create
    project = Project.find_by(hash_id: params[:project_hash_id])
    uri = URI(params[:repo_url])
    owner, repo = uri.path.split("/")[1..-1]

    clone = project.clones.new(students: params[:clone][:students], url: params[:repo_url], owner: owner, repo_name: repo)

    if clone.save
      ProjectBoardClonerWorker.perform_later(project, clone)
      redirect_to root_path, alert: "Thanks for your submission! Make sure your project cards are in the same order as the board located here: #{project.board_url}"
    else
      redirect_to root_path, alert: "We're sorry but we were unable to clone the project board. Make sure the link to your Github repo was entered correctly and try again. If you continue to experience difficulty reach out to your instructor or point of contact."
    end
  end
end
