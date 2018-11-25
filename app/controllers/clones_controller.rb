class ClonesController < ApplicationController
  skip_before_action :authenticate!

  def new
    @project = Project.find_by(hash_id: params[:project_id])
    @clone = @project.clones.new
    four_oh_four unless @project
  end

  def create
    project = Project.find_by(hash_id: params[:project_hash_id])
    clone = project.clones.new(clone_params)
    if clone.save
      message = "Thanks for your submission!"
    else
      message = "Sorry. Something went wrong. That's about all the details I can provide at the moment. Please try again or reach out to an instructor if you've seen this error multiple times."
    end

    redirect_to root_path, message: message
  end

  private

  def clone_params
    params.require(:clone).permit(:students, :owner, :repo_name)
  end
end
