class Admin::ClonesController < AdminBaseController
  def destroy
    project = Project.find_by(hash_id: params[:project_id])
    if project
      clone = Clone.find_by(id:params[:id])

      if clone && clone.destroy
        @message = "Clone was deleted successfully."
      else
        @message = "Unable to delete clone. Please try again."
      end
      redirect_to admin_project_path(project), alert: @message
    else
      @message = "Unable to find that project. Please try again."
      redirect_to dashboard_path, alert: @message
    end
  end
end
