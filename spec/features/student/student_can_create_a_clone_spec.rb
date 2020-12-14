require 'rails_helper'

feature 'User creates a new clone' do
  scenario 'with valid options' do
    instructor = create(:instructor, nickname: 'iandouglas')
    student = create(:student)
    project = create(:project, hash_id: 'abc123', user: instructor, project_board_base_url: 'https://github.com/turingschool/newb-tube/projects/1')

    mock_login(student)

    expect(ProjectBoardClonerWorker).to receive(:perform_later)#.with array_including(project, clone, "bambi@example.com")

    visit new_project_clone_path(project_id: project.hash_id)

    fill_in :students, with: 'Flower, Thumper, Bambi'
    fill_in :email, with: 'bambi@example.com'

    expect {
      click_on 'Submit'
    }.to change { Clone.count }.by(1)

    expect(current_path).to eq(root_path)
    expect(page).to have_content('Thanks for your submission!')
  end

  scenario 'student cannot create a clone when that project has been deleted by an admin' do
    instructor = create(:instructor, nickname: 'iandouglas')
    student = create(:student)
    project = create(:project, hash_id: 'abc123', user: instructor, project_board_base_url: 'https://github.com/turingschool/newb-tube/projects/1')

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(student)
    allow(ApprovedOrganizations).to receive(:all).and_return(%w(not-a-real-organization))

    visit new_project_clone_path(project_id: project.hash_id)

    fill_in :students, with: 'Flower, Thumper, Bambi'
    fill_in :email, with: 'bambi@example.com'

    # let's imagine here that an admin deletes a project, the clone will no longer save properly
    project.destroy

    click_on 'Submit'

    expect(current_path).to eq(root_path)
    expect(page).to have_content('we were unable to clone the project board')
  end

  describe 'when that clone already exists' do
    before :each do
      @clone = create(:clone)
      mock_login(@clone.user)

      @students = 'Dasher, Prancer, Vixen'
      @email = 'studentemail@gmail.com'
    end

    it 'does not create duplicates' do
      visit new_project_clone_path(@clone.project)

      fill_in :students, with: @students
      fill_in :email, with: @email

      click_button 'Submit'

      within '#new_clone' do
        expect(find('#students').value).to eq(@students)
      end

      expect(page).to have_content("We're sorry, it looks like you already have a clone created.")
    end

    it 'links to the show page for the existing clone' do
      visit new_project_clone_path(@clone.project)

      fill_in :students, with: @students
      fill_in :email, with: @email

      click_button 'Submit'

      expect(page).to have_content('Click here to view your clone.')
      expect(page).to have_link('Click here', href: clone_path(@clone))
    end
  end
end
