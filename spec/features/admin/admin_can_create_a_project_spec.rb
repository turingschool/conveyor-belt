require 'rails_helper'

feature "An admin logs in with GitHub" do
  scenario "it creates a new project", :vcr do
    instructor = create(:instructor, nickname: 'iandouglas')

    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(turingschool))

    visit root_path
    click_link "Sign in with GitHub"

    visit dashboard_path
    within '#new-project' do
      fill_in :project_name, with: 'My Cool Project'
      fill_in :project_project_board_base_url, with: 'https://abc/123'
      click_button('Create')
    end
    last_project = Project.last
    expect(current_path).to eq(admin_project_path(last_project))
    expect(page).to have_link new_project_clone_path(project_id: last_project.hash_id)
    expect(page).to have_link last_project.board_url

    visit dashboard_path
    within '#existing-projects' do
      expect(page).to have_link('My Cool Project')
    end

  end
end

