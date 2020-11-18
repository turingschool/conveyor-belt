require 'rails_helper'

feature "An admin logs in with GitHub" do
  scenario "it creates an account and makes them an admin", :vcr do
    instructor = create(:instructor, nickname: 'iandouglas')

    project = create(:project,
                     name: "BE3 Group Project",
                     user: instructor,
                     project_board_base_url: "https://github.com/turingschool-examples/watch-and-learn/projects/1",
                     github_column: 9804554
    )

    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(turingschool))

    visit root_path
    click_link "Sign in with GitHub"

    expect(current_path).to eq(dashboard_path)
    expect(page).to have_content("Sign out")
    expect(page).to have_link("Dashboard")

    within '#existing-projects' do
      expect(page).to have_link('BE3 Group Project')
    end

    within '#new-project' do
      expect(page).to have_content('give your project a name')
      expect(page).to have_css('#project_name')
      expect(page).to have_content('the link of the project board')
      expect(page).to have_css('#project_project_board_base_url')
      expect(page).to have_button('Create')
    end
  end
end

