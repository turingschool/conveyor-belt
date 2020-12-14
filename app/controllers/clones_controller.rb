class ClonesController < ApplicationController
  skip_before_action :authenticate!, only: [:new]

  def new
    @project = Project.find_by(hash_id: params[:project_id])
    four_oh_four unless @project

    @clone = @project.clones.new
    session[:previous_page] = new_project_clone_path(@project)
  end

  def create
    @project = Project.find_by(hash_id: params[:project_hash_id])
    if @project
      @clone = @project.clones.new(students: params[:students], user: current_user, url: '')
      if @clone.save
        @clone.update(message: 'sending to sidekiq')
        ProjectBoardClonerWorker.perform_later(@project, @clone, params[:email])
        redirect_to root_path, alert: "Thanks for your submission! We will send an email to #{params[:email]} when we finish getting everything setup. Follow the instructions in that message. Thanks!"
      else
        flash[:alert] = "We're sorry, it looks like you already have a clone created"
        render :new
      end
    else
      redirect_to root_path, alert: "We're sorry but we were unable to clone the project board."
    end
  end

  # def update
  #   project = current_user.projects.find_by(hash_id: params[:project_id])
  #   clone = project.clones.find(params[:id])
  #   ProjectBoardClonerWorker.perform_now(project, clone)
  #
  #   redirect_to admin_project_path(project), alert: "Cloning complete for #{clone.students}. Wait a minute and refresh the page."
  # end

  def clone_params
    params.require(:clone).permit(:url, :students)
  end
end
