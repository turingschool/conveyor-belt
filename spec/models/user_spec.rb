require 'rails_helper'
include Rails.application.routes.url_helpers

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many :projects }
  end
end
