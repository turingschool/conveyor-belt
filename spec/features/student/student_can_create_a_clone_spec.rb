require 'rails_helper'

feature 'User creates a new clone' do
  scenario 'with valid options' do
    # Sorry. This test is brittle but I'm rushing to get this out the door.
    # TODO: Use webmock instead of VCR to avoid issues if cassettes are deleted.
    # There's a lot of API calls to stub out so I took the easy path :grimacing:
    instructor = create(:instructor)
    project = create(:project,
           name: "BE3 Group Project",
           user: instructor,
           project_board_base_url: "https://github.com/turingschool-examples/watch-and-learn/projects/1",
           github_column: 9804554
    )

    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(not-a-real-organization))
    visit root_path
    click_link "Sign in with GitHub"

    visit new_project_clone_path(project_id: project.hash_id)
    fill_in :students, with: 'Flower, Thumper'
    fill_in :email, with: 'student@example.com'

    expect {
      click_button 'Submit'
    }.to change { Clone.count }.by(1)

    expect(current_path).to eq(root_path)
  end
end
