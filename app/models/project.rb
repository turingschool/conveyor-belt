class Project < ApplicationRecord
  belongs_to :user
  has_many :clones, dependent: :destroy

  before_create :set_hash_id

  alias_attribute :board_url, :project_board_base_url

  def set_hash_id
    hash_id = nil
    loop do
      hash_id = SecureRandom.urlsafe_base64(9).gsub(/-|_/,('a'..'z').to_a[rand(26)])
      break unless Project.exists?(hash_id: hash_id)
    end
    self.hash_id = hash_id
  end
end
