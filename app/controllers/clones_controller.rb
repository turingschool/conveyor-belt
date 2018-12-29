class ClonesController < ApplicationController
  skip_before_action :authenticate!, only: [:new, :create]

  def new
    @project = Project.find_by(hash_id: params[:project_id])
    @clone = @project.clones.new
    four_oh_four unless @project
  end

  def create
    #  create clone in DB
    #  fork repo to turingschool
    #  clone project board to forked repo
    #  transfer ownership to student
    #  display message for student to check email and accept transfer
    # check if current_user is member of org
    project = Project.find_by(hash_id: params[:project_hash_id])
    clone = project.clones.new(students: params[:students], owner: params[:github_handle])

    if clone.save
      ProjectBoardClonerWorker.perform_later(project, clone)
      redirect_to root_path, alert: "Thanks for your submission! You should see a board <a href='#{clone.url}/projects'>here</a> shortly. If you don't, reach out to your staff point person and let them know."
    else
      redirect_to root_path, alert: "We're sorry but we were unable to clone the project board. Make sure the link to your Github repo was entered correctly and try again. If you continue to experience difficulty reach out to your instructor or point of contact."
    end
  end

  def update
    project = current_user.projects.find_by(hash_id: params[:project_id])
    clone = project.clones.find(params[:id])
    ProjectBoardClonerWorker.perform_now(project, clone)

    redirect_to project, alert: "Recloning complete for #{clone.students}. Wait a minute and refresh the page."
  end

  def destroy
    project = current_user.projects.find_by(hash_id: params[:project_id])
    clone = project.clones.find(params[:id])

    if clone.destroy
      @message = "Successfully deleted clone."
    else
      @message = "Unable to delete clone. Please try again."
    end

    redirect_to project, alert: @message
  end

  def clone_params
    params.require(:clone).permit(:url, :students)
  end
end
