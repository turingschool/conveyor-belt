require 'rails_helper'

feature "An admin logs in with GitHub" do
  scenario "it creates an account and makes them an admin", :vcr do
    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(turingschool))

    visit root_path
    click_on "Sign in with GitHub"

    expect(current_path).to eq("/dashboard")
    expect(page).to have_content("Sign out")
    expect(page).to have_link("Dashboard")
  end
end

