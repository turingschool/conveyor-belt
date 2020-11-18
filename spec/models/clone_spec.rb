require 'rails_helper'
include Rails.application.routes.url_helpers

RSpec.describe Clone, type: :model do
  # let(:instructor) { create(:instructor) }
  # let(:student)    { create(:student, nickname: "ClassicRichard") }

  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :project }
  end

  describe 'validations' do
    it { should validate_presence_of :students }
  end
end
