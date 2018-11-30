FactoryBot.define do
  factory :project do
    name { "Conveyor Belt" }
    user
    hash_id { "abc123" }
    project_board_base_url { "https://github.com/jmejia/experimenting-with-projects/projects/15" }
  end
end

