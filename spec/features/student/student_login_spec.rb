require 'rails_helper'

feature "A student logs in with GitHub" do
  scenario "it creates an account but doesn't make them an admin", :vcr do
    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(not-a-real-organization))

    visit root_path
    click_on "Sign in with GitHub"

    expect(current_path).to eq("/dashboard")
    expect(page).to have_content("Sign out")
    expect(page).to_not have_link("Dashboard")
  end
end
