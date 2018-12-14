class ProjectBoardCloner
  attr_reader :project, :clone

  def initialize(project, clone)
    @project              = project
    @clone                = clone
    @cloned_project_board = nil
  end

  def run
    enable_issues_on_student_repo!
    clone_project_board!
    update_clone!
    create_columns!
  end

  def self.run(project, clone)
    new(project, clone).run
  end

  private
  attr_reader :cloned_project_board, :owner, :repo, :project_number

  def enable_issues_on_student_repo!
    Github::Repo.enable_issues!(owner: clone.owner, repo: clone.repo_name, access_token: project.token)
  end

  def clone_project_board!
    @cloned_project_board ||= client.create_board(clone.owner, clone.repo_name, project.name)
  end

  def update_clone!
    clone.update!(github_project_id: cloned_project_board[:id])
  end

  def create_columns!
    column_templates.each do |column_template|
      ColumnCloner.run(column_template, clone, client)
    end
  end

  def client
    @client ||= GithubService.new(token: project.user.token)
  end

  def base_project
    github_projects.find { |p| p[:number] == project_number.to_i }
  end

  def github_projects
    uri = URI(project.project_board_base_url)
    @owner, @repo, @_projects_segment, @project_number = uri.path.split("/")[1..-1]
    @github_projects ||= client.projects(owner, repo)
  end

  def column_templates
    client.columns(base_project[:id])
  end
end
