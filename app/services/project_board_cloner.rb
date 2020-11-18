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
      write_message("getting started!")
      turn_on_auto_paginate!
      fork_repo!
      invite_staff_member_to_repo!
      accept_repo_invitation!
      enable_issues!
      clone_project_board!
      update_clone!
      create_columns!
      add_to_dashboard_project!
      email_student!
      write_message("all done!")
    rescue => e
      write_message(e.message)
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

  def fork_repo!
    write_message("Forking repo to student account.")
    @forked_repo = student_client.fork(project.repo_path)
  end

  def invite_staff_member_to_repo!
    write_message("Inviting staff member to student repo.")
    student_client.invite_user_to_repository(forked_repo.full_name, project.user.nickname)
  end

  def accept_repo_invitation!
    write_message("Accepting staff invitations.")
    page, per_page = 1, 100
    no_more_invitations, found_invitation = false, false
    invites = []

    until no_more_invitations # || found_invitation
      invitations = staff_client.user_repository_invitations(page: page, per_page: per_page)

      invites << invitations.find_all do |invite|
        invite.repository.full_name == forked_repo.full_name
      end
      invites.flatten!

      if invitations.count < per_page
        no_more_invitations = true
      end

      page += 1
    end

    invites.flatten!
    invites.each do |invite|
      staff_client.accept_repository_invitation(invite.id)
    end

    # if found_invitation
    #   staff_client.accept_repo_invitation(found_invitation.id)
    # else
    #   raise Octokit::NotFound
    # end
  end

  def clone_project_board!
    write_message("Cloning project board.")
    @cloned_project_board ||= student_client.create_project(repo_path, project.name)
  end

  def enable_issues!
    write_message("Enabling issues on student repo.")
    student_client.edit_repository(repo_path, has_issues: true)
  end

  def update_clone!
    write_message("Saving GitHub project id in the database.")
    clone.update!(github_project_id: cloned_project_board.id, url: cloned_project_board.html_url)
  end

  def create_columns!
    column_templates.each.with_index(1) do |column_template, index|
      write_message("Creating column #{index}.")
      ColumnCloner.run!(column_template, forked_repo, clone.github_project_id, staff_client)
    end
  end

  def add_to_dashboard_project!
    write_message("Adding reference to dashboard project.")
    staff_client.create_project_card(project.github_column, note: cloned_project_board.html_url)
  end

  def email_student!
    write_message("sending email to student")
    CloneMailer.with(email: email, clone: clone).send_notification.deliver_now
  end

  def write_message(message)
    @clone.update(message: message)
    @clone.save!
  end

  def base_project
    github_projects.find { |p| p.number == project_number.to_i }
  end

  def github_projects
    uri = URI(project.project_board_base_url)
    @owner, @repo, @_projects_segment, @project_number = uri.path.split("/")[1..-1]
    @github_projects ||= staff_client.projects([owner, repo].join("/"))
  end

  def column_templates
    staff_client.project_columns(base_project.id)
  end

  def repo_path
    "#{forked_repo.owner.login}/#{forked_repo.name}"
  end

  def turn_on_auto_paginate!
    write_message("enabling auto_paginate for staff")
    staff_client.auto_paginate = true
    write_message("enabling auto_paginate for students")
    student_client.auto_paginate = true
  end
end

