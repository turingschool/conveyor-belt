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
end
