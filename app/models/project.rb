class Project < ApplicationRecord
  belongs_to :user
  has_many :clones, dependent: :destroy

  before_create :set_hash_id

  alias_attribute :board_url, :project_board_base_url
  delegate :token, to: :user

  def to_param
    hash_id
  end

  def set_hash_id
    hash_id = nil
    loop do
      hash_id = SecureRandom.urlsafe_base64(9).gsub(/-|_/,('a'..'z').to_a[rand(26)])
      break unless Project.exists?(hash_id: hash_id)
    end
    self.hash_id = hash_id
  end

  def repo_path
    url_segments = URI(project_board_base_url).path.split("/")

    [url_segments[1], url_segments[2]].join("/")
  end

  def get_clones
    clones.joins(:user)
        .where(project: self)
        .order('users.nickname asc, users.email asc, clones.created_at desc')
  end
end
