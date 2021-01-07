FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    uid { 'NoID' }
    token { 'NotaRealToken' }
    nickname { 'NoNickname123456789' }
    email { Faker::Internet.email }
    admin { false }
  end

  factory :student, parent: :user do
    name { Faker::Name.name }
    uid { '11797474' }
    token { ENV['GITHUB_TESTING_STUDENT_TOKEN'] }
    nickname { 'ClassicRichard' }
    email { Faker::Internet.email }
    admin { false }
  end

  factory :instructor, aliases: [:staff], parent: :user do
    name { Faker::Name.name }
    uid { '168030' }
    token { ENV['GITHUB_TESTING_USER_TOKEN'] }
    nickname { 'iandouglas' }
    email { Faker::Internet.email }
    admin { true }
  end
end
