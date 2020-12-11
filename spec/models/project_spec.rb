require 'rails_helper'
include Rails.application.routes.url_helpers

RSpec.describe Project, type: :model do
  let(:instructor) { create(:instructor) }
  let(:student)    { create(:student, nickname: "ClassicRichard") }

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many(:clones) }
  end

  describe 'methods' do
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

    scenario '.get_clones' do
      project = create(:project, user: instructor, project_board_base_url: 'http://github.com/ian/douglas')
      student_2 = create(:student, nickname: 'AwesomeCoder')
      student_3 = create(:student, nickname: 'ZeroCool')
      s1_clone_1 = create(:clone, project: project, user: student, created_at: 10.seconds.ago)   # 3rd
      s1_clone_2 = create(:clone, project: project, user: student, created_at: 5.seconds.ago)    # 2nd
      s2_clone_1 = create(:clone, project: project, user: student_2, created_at: 10.seconds.ago) # 1st
      s3_clone_1 = create(:clone, project: project, user: student_3, created_at: 5.seconds.ago)  # 4th
      s3_clone_2 = create(:clone, project: project, user: student_3, created_at: 10.seconds.ago) # 5th

      clone_list = project.get_clones
      expect(clone_list[0].id).to eq(s2_clone_1.id)
      expect(clone_list[1].id).to eq(s1_clone_2.id)
      expect(clone_list[2].id).to eq(s1_clone_1.id)
      expect(clone_list[3].id).to eq(s3_clone_1.id)
      expect(clone_list[4].id).to eq(s3_clone_2.id)
    end
  end
end
