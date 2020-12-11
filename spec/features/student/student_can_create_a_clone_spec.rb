require 'rails_helper'

feature 'User creates a new clone' do
  scenario 'with valid options' do
    student = create(:student)
    project = create(:project, hash_id: 'abc123', user: student, project_board_base_url: 'https://github.com/turingschool/newb-tube/projects/1')
    clone = create(:clone,
                   students: 'Richard H.',
                   project: project,
                   user: student,
                   url: 'http://abc/123'
    )
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(student)
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(not-a-real-organization))

    expect(ProjectBoardClonerWorker).to receive(:perform_later)#.with array_including(project, clone, "bambi@example.com")

    visit new_project_clone_path(project_id: project.hash_id)

    fill_in :students, with: 'Flower, Thumper, Bambi'
    fill_in :email, with: 'bambi@example.com'

    expect {
      click_on 'Submit'
    }.to change { Clone.count }.by(1)

    expect(current_path).to eq(root_path)
  end

  scenario 'admin can delete clone' do
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

    expect(page).to have_content(clone.url)
    click_link 'Delete'

    expect(current_path).to eq(admin_project_path(project))
    expect(page).to_not have_content(clone.url)
  end
end
