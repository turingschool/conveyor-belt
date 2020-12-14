FactoryBot.define do
  factory :clone do
    students  {"Richard H." }
    project
    user { create(:student) }
    url { nil }
    github_project_id { nil }
    message { "" }
  end
end
