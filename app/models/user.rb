class User < ApplicationRecord
  has_many :projects, dependent: :destroy

  def self.from_omniauth(auth)
    User.find_or_create_by(uid: auth.uid) do |user|
      user.nickname = auth.info.nickname
      user.token = auth.credentials.token
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end
end
