require 'rails_helper'

feature 'User creates a new clone' do
  scenario 'with valid options' do
    # Sorry. This test is brittle but I'm rushing to get this out the door.
    # TODO: Use webmock instead of VCR to avoid issues if cassettes are deleted.
    # There's a lot of API calls to stub out so I took the easy path :grimacing:
    user = create(:user, nickname: "jmejia")

    project = create(:project, hash_id: "abc123", user: user, project_board_base_url: "https://github.com/turingschool/newb-tube/projects/1")

    visit new_project_clone_path(project_id: project.hash_id)

    expect(page).to have_content("Please add jmejia as a collaborator to your repo")

    fill_in :clone_students, with: "Flower, Thumper"
    fill_in :clone_owner, with: "jmejia"
    fill_in :clone_repo_name, with: "experimenting-with-projects"

    expect {
      click_on "Submit"
    }.to change { Clone.count }.by(1)

    expect(current_path).to eq(root_path)
  end
end
