require 'rails_helper'

RSpec.describe Project, type: :model do
  include Rails.application.routes.url_helpers

  let(:instructor) { create(:instructor) }
  let(:student)    { create(:student, nickname: "ClassicRichard") }

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many(:clones) }
  end

  describe 'instance methods' do
    scenario '.to_param' do
      project = create(:project, user: instructor)
      expect(admin_project_path(project)).to eq("/admin/projects/#{project.hash_id}")
    end

    scenario '.set_hash_id' do
      project = create(:project, user: instructor)
      project.hash_id = 'abc123'
      project.save!

      project.set_hash_id

      expect(project.hash_id).to_not eq('abc123')
    end

    scenario '.repo_path' do
      project = create(:project, user: instructor, project_board_base_url: 'http://github.com/ian/douglas')

      expect(project.repo_path).to eq('ian/douglas')
    end

    describe '.get_clones' do
      it 'orders by user nickname, user email, and clone created at timestamp' do
        project = create(:project, user: instructor, project_board_base_url: 'http://github.com/ian/douglas')

        student_1 = create(:student, nickname: 'ZeroChill', email: 'ZeroChill@gmail.com')
        student_2 = create(:student, nickname: 'BigSpender', email: 'BigSpender@gmail.com')
        student_3 = create(:student, nickname: 'AllStar', email: 'AllStar@gmail.com')
        student_4 = create(:student, nickname: 'Yessirybob', email: 'Yessirybob@gmail.com')
        student_5 = create(:student, nickname: 'Yessirybob', email: 'Yessirybob@gmail.com')
        student_6 = create(:student, nickname: 'Yessirybob', email: 'Nosirybob@gmail.com')

        clone_1 = create(:clone, project: project, user: student_1, created_at: 10.seconds.ago)   # 3rd
        clone_2 = create(:clone, project: project, user: student_2, created_at: 5.seconds.ago)    # 2nd
        clone_3 = create(:clone, project: project, user: student_3, created_at: 10.seconds.ago) # 1st
        clone_4 = create(:clone, project: project, user: student_4, created_at: 5.seconds.ago)  # 4th
        clone_5 = create(:clone, project: project, user: student_5, created_at: 10.seconds.ago) # 5th
        clone_6 = create(:clone, project: project, user: student_6, created_at: 10.seconds.ago) # 5th

        clone_list = project.get_clones
        expect(clone_list[0].id).to eq(clone_3.id)
        expect(clone_list[1].id).to eq(clone_2.id)
        expect(clone_list[2].id).to eq(clone_6.id)
        expect(clone_list[3].id).to eq(clone_4.id)
        expect(clone_list[4].id).to eq(clone_5.id)
        expect(clone_list[5].id).to eq(clone_1.id)
      end

      it 'does not return clones from different projects' do
        project = create(:project, user: instructor, project_board_base_url: 'http://github.com/ian/douglas')
        different_clone = create(:clone)
        expect(project.get_clones).to_not include(different_clone)
      end
    end
  end
end
