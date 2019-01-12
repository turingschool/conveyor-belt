class DashboardCreatorJob < ApplicationJob
  queue_as :default

  def perform(project)
    client = Octokit::Client.new(access_token: project.user.token)

    github_project = client.create_project(project.repo_path, "Dashboard")

    column = client.create_project_column(github_project.id, "Icetown")

    puts "================================="
    puts column.id
    puts github_project.html_url
    puts "================================="

    project.update!(dashboard_url: github_project.html_url, github_column: column.id)
  end
end
