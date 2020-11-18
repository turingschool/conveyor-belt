require 'rails_helper'

RSpec.describe ApprovedOrganizations do
  describe 'methods' do
    scenario '#all' do
      expect(ApprovedOrganizations.all).to eq(['turingschool'])
    end
  end
end
