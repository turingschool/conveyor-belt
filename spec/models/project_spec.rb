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
  end
end
