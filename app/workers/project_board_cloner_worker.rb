class ProjectBoardClonerWorker < ActiveJob::Base
  queue_as :default

  def perform(project, clone)
    ProjectBoardCloner.run(project, clone)
  end
end
