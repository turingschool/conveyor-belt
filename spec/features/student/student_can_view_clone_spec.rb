require 'rails_helper'

feature 'User visits clone show page' do
  it 'displays the clone repo link and message' do
    clone = create(:clone)
    student = clone.user

    mock_login(student)

    visit clone_path(clone)

    expect(page).to have_link('View your repo on GitHub', href: clone.url)
    expect(page).to have_content("Students working on this project: #{clone.students}")
    expect(page).to have_content("Status: #{clone.message}")
    expect(page).to have_content("Clone of Project #{clone.project.name}")
  end

  it 'does not allow you to view another students clone' do
    clone = create(:clone)
    different_student = create(:student)

    mock_login(different_student)

    expect { visit clone_path(clone) }.to raise_error(ActionController::RoutingError)
  end

  it 'does not show repo link if repo has not been successfully created' do
    clone = create(:clone, url: "")
    student = clone.user

    mock_login(student)

    visit clone_path(clone)

    expect(page).to_not have_link("View your repo on GitHub")
  end
end
