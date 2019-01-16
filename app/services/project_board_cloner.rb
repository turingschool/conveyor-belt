class ProjectBoardCloner
  attr_reader :project, :clone, :message

  def initialize(project, clone, email)
    @project              = project
    @clone                = clone
    @email                = email
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
      add_to_dashboard_project!
      email_student!
      write_message!
    rescue => e
      write_message!
      raise e
    end

    return self
  end

  def self.run(project, clone, email)
    new(project, clone, email).run
  end

  private
  attr_reader :cloned_project_board, :owner, :repo, :email,
    :project_number, :forked_repo, :staff_client, :student_client

  def target_github_repo
    @target_github_repo ||= Github::Repo.new(owner: clone.owner, repo: clone.repo_name, access_token: project.token)
  end

  def fork_repo!
    @message = "Forking repo to student account."
    @forked_repo = student_client.fork(project.repo_path)
  end

  def invite_staff_member_to_repo!
    @message = "Inviting staff member to student repo."
    student_client.invite_user_to_repo(forked_repo.full_name, project.user.nickname)
  end

  def accept_repo_invitation!
    @message = "Accepting staff invitation."
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
      @message = "Invitation not found. Have the student delete their repo and try again."
    end
  end

  def clone_project_board!
    @message = "Cloning project board."
    @cloned_project_board ||= client.create_board(forked_repo.owner.login, forked_repo.name, project.name)
  end

  def enable_issues!
    @message = "Enabling issues on student repo."
    Github::Repo.enable_issues!(owner: forked_repo.owner.login, repo: forked_repo.name, access_token: clone.user.token)
  end

  def update_clone!
    @message = "Saving GitHub project id in the database."
    clone.update!(github_project_id: cloned_project_board[:id], url: cloned_project_board[:html_url])
  end

  def create_columns!
    column_templates.each.with_index(1) do |column_template, index|
      @message = "Creating column #{index}."
      ColumnCloner.run(column_template, forked_repo, clone.github_project_id, client)
    end
  end

  def add_to_dashboard_project!
    @message = "Adding reference to dashboard project."
    staff_client.create_project_card(project.github_column, note: cloned_project_board[:html_url])
  end

  def email_student!
    CloneMailer.with(email: email, clone: clone).send_notification.deliver_now
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

