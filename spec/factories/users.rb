FactoryBot.define do
  factory :user do
    name { 'Plain User' }
    uid { 'NoID' }
    token { 'NotaRealToken' }
    nickname { 'NoNickname123456789' }
    email { 'admin@example.com' }
    admin { false }
  end

  factory :student, parent: :user do
    name { 'Richard B. Hathaway' }
    uid { '11797474' }
    token { ENV['GITHUB_TESTING_STUDENT_TOKEN'] }
    nickname { 'ClassicRichard' }
    email { 'student@example.com' }
    admin { false }
  end

  factory :instructor, parent: :user do
    name { 'Ian Douglas' }
    uid { '168030' }
    token { ENV['GITHUB_TESTING_USER_TOKEN'] }
    nickname { 'iandouglas' }
    email { 'iandouglas@turing.io' }
    admin { true }
  end
end

