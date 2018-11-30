class ClonesController < ApplicationController
  skip_before_action :authenticate!

  def new
    @project = Project.find_by(hash_id: params[:project_id])
    @clone = @project.clones.new
    four_oh_four unless @project
  end

  def create
    project = Project.find_by(hash_id: params[:project_hash_id])
    service = GithubService.new(token: project.user.token)

    # retrieve base project id
    uri = URI(project.project_board_base_url)
    owner, repo, projects_segment, project_number = uri.path.split("/")[1..-1]
    gh_projects = service.projects(owner, repo)

    base_project    = gh_projects.find { |p| p[:number] == project_number.to_i }
    base_project_id = base_project[:id]

    # retrieve the columns
    column_templates = service.columns(base_project_id)

    # retrieve the cards from each column

    # create the project board
    body = { name: project.name }.to_json

    clone = project.clones.new(clone_params)

    response = service.create_board(clone.owner, clone.repo_name, body)
    cloned_project_id = JSON.parse(response.body, symbolize_names: true)[:id]

    column_templates.each do |column_template|
      cloned_column = service.create_column(cloned_project_id, column_template[:name])
      # find existing cards template column
      template_cards = service.cards(column_template[:id])

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






    if clone.save
      message = "Thanks for your submission!"
    else
      message = "Sorry. Something went wrong. That's about all the details I can provide at the moment. Please try again or reach out to an instructor if you've seen this error multiple times."
    end

    redirect_to root_path, message: message
  end

  private

  def clone_params
    params.require(:clone).permit(:students, :owner, :repo_name)
  end
end
