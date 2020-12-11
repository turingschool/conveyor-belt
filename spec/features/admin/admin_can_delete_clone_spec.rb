require 'rails_helper'

feature 'admin can interact with student repo clones' do
  scenario 'admin can delete clone of a project they made' do
    instructor = create(:instructor, nickname: 'iandouglas')

    project = create(:project,
                     name: "BE3 Group Project",
                     user: instructor,
                     project_board_base_url: "https://github.com/turingschool-examples/watch-and-learn/projects/1",
                     github_column: 9804554
    )
    student = create(:student)
    clone = create(:clone,
                   students: 'Richard H.',
                   project: project,
                   user: student,
                   url: 'http://abc/123'
    )
    mock_login(instructor)

    visit admin_project_path(project)

    expect(page).to have_content(clone.url)
    within ".project-#{project.id}" do
      click_link 'Delete'
    end

    expect(current_path).to eq(admin_project_path(project))
    expect(page).to_not have_content(clone.url)
    expect(page).to have_content("Clone was deleted successfully")
  end

  scenario 'admin can delete clone of a project made by another admin' do
    instructor_1 = create(:instructor, nickname: 'iandouglas')
    instructor_2 = create(:instructor, nickname: 'brianzanti')

    project = create(:project,
                     name: "BE3 Group Project",
                     user: instructor_1,
                     project_board_base_url: "https://github.com/turingschool-examples/watch-and-learn/projects/1",
                     github_column: 9804554
    )
    student = create(:student)
    clone = create(:clone,
                   students: 'Richard H.',
                   project: project,
                   user: student,
                   url: 'http://abc/123'
    )

    mock_login(instructor_2)

    visit admin_project_path(project)

    expect(page).to have_content(clone.url)
    within ".project-#{project.id}" do
      click_link 'Delete'
    end

    expect(current_path).to eq(admin_project_path(project))
    expect(page).to_not have_content(clone.url)
    expect(page).to have_content("Clone was deleted successfully")
  end

  scenario 'handles a race condition gracefully if multiple admins delete a clone at the same time' do
    instructor = create(:instructor, nickname: 'iandouglas')

    project = create(:project,
                     name: "BE3 Group Project",
                     user: instructor,
                     project_board_base_url: "https://github.com/turingschool-examples/watch-and-learn/projects/1",
                     github_column: 9804554
    )
    student = create(:student)
    clone = create(:clone,
                   students: 'Richard H.',
                   project: project,
                   user: student,
                   url: 'http://abc/123'
    )

    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(turingschool))
    visit root_path
    click_link "Sign in with GitHub"

    visit admin_project_path(project)

    # let's imagine here that another admin has logged in and deleted this clone already
    clone.destroy

    expect(page).to have_content(clone.url)
    within ".project-#{project.id}" do
      click_link 'Delete'
    end

    expect(current_path).to eq(admin_project_path(project))
    expect(page).to_not have_content(clone.url)
    expect(page).to have_content("Unable to delete clone. Please try again.")
  end


  scenario 'handles a race condition when a whole project gets deleted' do
    instructor = create(:instructor, nickname: 'iandouglas')

    project = create(:project,
                     name: "BE3 Group Project",
                     user: instructor,
                     project_board_base_url: "https://github.com/turingschool-examples/watch-and-learn/projects/1",
                     github_column: 9804554
    )
    student = create(:student)
    clone = create(:clone,
                   students: 'Richard H.',
                   project: project,
                   user: student,
                   url: 'http://abc/123'
    )

    stub_omniauth
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(turingschool))
    visit root_path
    click_link "Sign in with GitHub"

    visit admin_project_path(project)

    # let's imagine here that another admin has logged in and deleted this whole project
    project.destroy

    expect(page).to have_content(clone.url)
    within ".project-#{project.id}" do
      click_link 'Delete'
    end

    expect(current_path).to eq(dashboard_path)
    expect(page).to have_content("Unable to find that project. Please try again.")
  end
end
