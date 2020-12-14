FactoryBot.define do
  factory :project do
    name { Faker::Company.catch_phrase }
    user { create(:staff) }
    hash_id { Faker::Crypto.md5 }
    project_board_base_url { Faker::Internet.url }
  end
end
