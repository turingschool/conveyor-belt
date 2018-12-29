class ProjectBoardCloner
  attr_reader :project, :clone, :message

  def initialize(project, clone)
    @project              = project
    @clone                = clone
    @cloned_project_board = nil
    @message              = ""
  end

  def run
    begin
      # confirm_invitation!
      # confirm_collaborator!
      # enable_issues_on_student_repo!
      clone_project_board!
      update_clone!
      create_columns!
    rescue => e # rescue every failure and write the message
      @message = [@message, e.message].uniq.join(", ")
    end

    write_message!
    return self
  end

  def self.run(project, clone)
    new(project, clone).run
  end

  private
  attr_reader :cloned_project_board, :owner, :repo, :project_number

  def target_github_repo
    @target_github_repo ||= Github::Repo.new(owner: clone.owner, repo: clone.repo_name, access_token: project.token)
  end

  def clone_project_board!
    repo_name = [project.name, clone.students].join("-").parameterize
    repo_path = ["turingschool", repo_name].join("/") # can we have more than one fork?
    staff_client = Octokit::Client.new(access_token: project.user.token)
    # student_client = Octokit::Client.new()

    url_segments = URI(project.project_board_base_url).path.split("/")
    source_repo_path = [url_segments[1], url_segments[2]].join("/")
    forked_repo = client.fork(source_repo_path)
    # client.clone_board
    # transfer ownership
    # student_client accept transfer
    #

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

  def write_message!
    clone.update(message: message)
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

