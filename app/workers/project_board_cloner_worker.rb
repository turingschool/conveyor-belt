class ProjectBoardClonerWorker < ActiveJob::Base
  queue_as :default

  def perform(project, clone, email)
    ProjectBoardCloner.run(project, clone, email)
  end
end
