FactoryBot.define do
  factory :user do
    name { "Josh Mejia" }
    uid { "73824" }
    token { ENV['GITHUB_TESTING_USER_TOKEN'] }
    nickname { "jmejia" }
    email { "josh@example.com" }
  end
end

