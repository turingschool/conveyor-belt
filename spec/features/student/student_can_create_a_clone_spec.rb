require 'rails_helper'

feature 'User creates a new clone' do
  describe 'with valid options' do
    before :each do
      @student = create(:student)
      @project = create(:project)
      mock_login(@student)
    end

    scenario 'it creates successfully' do
      expect(ProjectBoardClonerWorker).to receive(:perform_later)#.with array_including(project, clone, "bambi@example.com")

      visit new_project_clone_path(project_id: @project.hash_id)

      fill_in :students, with: 'Flower, Thumper, Bambi'
      fill_in :email, with: 'bambi@example.com'

      expect {
        click_on 'Submit'
      }.to change { Clone.count }.by(1)

      expect(current_path).to eq(root_path)
      expect(page).to have_content('Thanks for your submission!')
    end

    scenario 'their email is prepopulated in the form' do
      visit new_project_clone_path(project_id: @project.hash_id)

      expect(find('#email').value).to eq(@student.email)
    end

    scenario 'student cannot create a clone when that project has been deleted by an admin' do
      visit new_project_clone_path(project_id: @project.hash_id)

      fill_in :students, with: 'Flower, Thumper, Bambi'
      fill_in :email, with: 'bambi@example.com'

      # let's imagine here that an admin deletes a project, the clone will no longer save properly
      @project.destroy

      click_on 'Submit'

      expect(current_path).to eq(root_path)
      expect(page).to have_content('we were unable to clone the project board')
    end
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
