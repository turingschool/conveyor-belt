FactoryBot.define do
  factory :project do
    name { "Conveyor Belt" }
    user { staff }
    hash_id { "abc123" }
    project_board_base_url { "https://github.com/turingschool-examples/watch-and-learn/projects/1" }
  end
end
