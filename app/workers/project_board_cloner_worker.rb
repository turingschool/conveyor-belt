class ProjectBoardClonerWorker < ActiveJob::Base
  queue_as :default

  def perform(project, clone)
    service = GithubService.new(token: project.user.token)

    # retrieve base project id
    uri = URI(project.project_board_base_url)
    owner, repo, _projects_segment, project_number = uri.path.split("/")[1..-1]
    gh_projects = service.projects(owner, repo)
    base_project    = gh_projects.find { |p| p[:number] == project_number.to_i }
    base_project_id = base_project[:id]

    # retrieve the columns
    column_templates = service.columns(base_project_id)

    # retrieve the cards from each column

    # create the project board
    body = { name: project.name }.to_json


    response = service.create_board(clone.owner, clone.repo_name, body)
    cloned_project_id = JSON.parse(response.body, symbolize_names: true)[:id]

    column_templates.each do |column_template|
      cloned_column = service.create_column(cloned_project_id, column_template[:name])
      # find existing cards template column
      template_cards = service.cards(column_template[:id]).reverse

      template_cards.each do |template_card|
        if template_card[:content_url] # it's an issue
          # retrieve the issue
          base_issue = service.issue(template_card[:content_url])

          # create the cloned issue
          content = {
            title: base_issue[:title],
            body:  base_issue[:body],
            labels: base_issue[:labels].map { |i| i[:name] }
          }
          cloned_issue = service.create_issue(clone.owner, clone.repo_name, content)

          # create the card
          cloned_card = service.create_issue_card(cloned_column[:id], cloned_issue[:id])
        else # it's a note
          service.create_note_card(cloned_column[:id], template_card[:note])
        end
      end
    end

  end
end
