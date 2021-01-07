FactoryBot.define do
  factory :clone do
    students  {"#{Faker::Name.name}, #{Faker::Name.name}, #{Faker::Name.name}" }
    project
    user { create(:student) }
    url { Faker::Internet.url }
    github_project_id { nil }
    message { Faker::ChuckNorris.fact }
  end
end
