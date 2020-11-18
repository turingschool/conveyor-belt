require 'rails_helper'

feature "A student logs in with GitHub" do
  scenario "it creates an account but doesn't make them an admin", :vcr do
    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(not-a-real-organization))
    visit root_path
    click_link "Sign in with GitHub"

    expect(current_path).to eq(dashboard_path)
    expect(page).to have_content("Signed in!")
    expect(page).to have_link("Sign out")
    expect(page).to_not have_link("Dashboard")

    click_link "Sign out"

    expect(current_path).to eq(root_path)
    expect(page).to have_link("Sign in with GitHub")
  end

  scenario 'login path works' do
    visit login_path
    expect(page).to have_link("Sign in with GitHub")
  end

  scenario 'login works but throws 404 if trying to go to admin areas' do
    user = create(:user, nickname: 'jmejia')
    project = create(:project, hash_id: 'abc123', user: user, project_board_base_url: 'https://github.com/turingschool/newb-tube/projects/1')

    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(not-a-real-organization))
    visit root_path
    click_link "Sign in with GitHub"

    expect{visit admin_project_path(project)}.to raise_error ActionController::RoutingError
  end
end
