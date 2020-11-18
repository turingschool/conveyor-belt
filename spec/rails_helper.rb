# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

SimpleCov.start "rails"
SimpleCov.add_filter %w[spec lib config app/channels app/helpers app/workers]

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = { re_record_interval: 1.year, record: :new_episodes }
  config.filter_sensitive_data('<GITHUB_KEY>') { ENV['GITHUB_KEY'] }
  config.filter_sensitive_data('<GITHUB_SECRET>') { ENV['GITHUB_SECRET'] }
  config.filter_sensitive_data('<GITHUB_TESTING_USER_TOKEN>') { ENV['GITHUB_TESTING_USER_TOKEN'] }
  config.filter_sensitive_data('<GITHUB_TESTING_STUDENT_TOKEN>') { ENV['GITHUB_TESTING_STUDENT_TOKEN'] }
end

def stub_omniauth
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
    uid: "168030",
    info: {
      nickname: "iandouglas",
      name: "Ian Douglas",
      email: "iandouglas@turing.io"
    },
    credentials: {
      token: ENV['GITHUB_TESTING_USER_TOKEN']
    }
  })
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
