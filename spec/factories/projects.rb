FactoryBot.define do
  factory :project do
    name { "Conveyor Belt" }
    user { staff }
    hash_id { "abc123" }
    project_board_base_url { "https://github.com/turingschool-examples/brownfield-of-dreams/projects/1" }
  end
end

