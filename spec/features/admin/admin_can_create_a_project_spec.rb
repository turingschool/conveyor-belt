require "rails_helper"

feature "An admin can create a project" do
  scenario "when filling in valid information" do
    staff = create(:staff)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(staff)

    visit dashboard_path
    expect(current_path).to eq("/dashboard")

    fill_in "project_name", with: "Brownfield of Dreams"
    fill_in "project_project_board_base_url", with: "https://github.com/turingschool-examples/brownfield-of-dreams/projects/1"
    expect {
      click_on "Create"
    }.to change { staff.projects.count }.by(1)

    expect(current_path).to eq admin_project_path(staff.projects.last.hash_id)
  end
end
