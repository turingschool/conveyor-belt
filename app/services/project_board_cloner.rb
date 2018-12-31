class ProjectBoardCloner
  attr_reader :project, :clone, :message

  def initialize(project, clone)
    @project              = project
    @clone                = clone
    @staff_client         = Octokit::Client.new(access_token: project.user.token)
    @student_client       = Octokit::Client.new(access_token: clone.user.token)
    @cloned_project_board = nil
    @message              = ""
  end

  def run
    begin
      fork_repo!
      invite_staff_member_to_repo!
      accept_repo_invitation!
      enable_issues!
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
  attr_reader :cloned_project_board, :owner, :repo,
    :project_number, :forked_repo, :staff_client, :student_client

  def target_github_repo
    @target_github_repo ||= Github::Repo.new(owner: clone.owner, repo: clone.repo_name, access_token: project.token)
  end

  def fork_repo!
    url_segments = URI(project.project_board_base_url).path.split("/")
    source_repo_path = [url_segments[1], url_segments[2]].join("/")
    @forked_repo = student_client.fork(source_repo_path)
  end

  def invite_staff_member_to_repo!
    student_client.invite_user_to_repo(forked_repo.full_name, project.user.nickname)
  end

  def accept_repo_invitation!
    page, per_page = 1, 100
    no_more_invitations, found_invitation = false, false

    until no_more_invitations || found_invitation
      invitations = staff_client.user_repository_invitations(page: page, per_page: per_page)

      found_invitation = invitations.find do |invite|
        invite.repository.full_name == forked_repo.full_name
      end

      if invitations.count < per_page
        no_more_invitations = true
      end

      page += 1
    end

    if found_invitation
      staff_client.accept_repo_invitation(found_invitation.id)
    else
      raise Octokit::NotFound
    end
  end

  def clone_project_board!
    @cloned_project_board ||= client.create_board(forked_repo.owner.login, forked_repo.name, project.name)
  end

  def enable_issues!
    Github::Repo.enable_issues!(owner: forked_repo.owner.login, repo: forked_repo.name, access_token: clone.user.token)
  end

  def update_clone!
    clone.update!(github_project_id: cloned_project_board[:id])
  end

  def create_columns!
    column_templates.each do |column_template|
      ColumnCloner.run(column_template, forked_repo, clone.github_project_id, client)
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

