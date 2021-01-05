require 'rails_helper'

RSpec.describe Clone, type: :model do
  # let(:instructor) { create(:instructor) }
  # let(:student)    { create(:student, nickname: "ClassicRichard") }

  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :project }
  end

  describe 'validations' do
    it { should validate_presence_of :students }

    describe 'project and student uniqueness' do
      it 'validates the uniqueness of the student AND the project simultaneously' do
        project = create(:project)
        student = create(:student)
        clone = Clone.create(project: project, user: student, students: '1, 2, 3')
        expect(clone).to be_valid
        duplicate_clone = Clone.create(project: project, user: student, students: '4, 5, 6')
        expect(duplicate_clone).to be_invalid
      end

      it 'is still valid if the student or the project are different' do
        project = create(:project)
        student = create(:student)
        clone = Clone.create(project: project, user: student, students: '1, 2, 3')
        different_user_clone = Clone.create(project: project, user: create(:student), students: '1, 2, 3')
        different_project_clone = Clone.create(project: create(:project), user: student, students: '1, 2, 3')
        expect(different_user_clone).to be_valid
        expect(different_project_clone).to be_valid
      end
    end
  end

  describe 'instance methods' do
    describe '#valid_url?' do
      it 'treats a github repo url as valid' do
        clone = create(:clone, url: 'https://github.com/agallant121/adopt_dont_shop_2005')
        expect(clone.valid_url?).to be(true)
      end

      it 'does not treat nil as valid' do
        clone = create(:clone, url: nil)
        expect(clone.valid_url?).to be(false)
      end

      it 'does not treat an empty string as valid' do
        clone = create(:clone, url: "")
        expect(clone.valid_url?).to be(false)
      end
    end
  end
end
