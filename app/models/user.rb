class User < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :clones, dependent: :destroy

  def self.from_omniauth(auth)
    User.find_or_create_by(uid: auth.uid) do |user|
      is_admin = false
      client = Octokit::Client.new(access_token: auth.credentials.token)
      approved_orgs = ApprovedOrganizations.all
      found_org = client.orgs.find { |org| org.login.in?(approved_orgs) }

      is_admin = true if found_org

      user.admin = is_admin
      user.nickname = auth.info.nickname
      user.token = auth.credentials.token
      user.name = auth.info.name
      user.email = auth.info.email
    end
  end
end
