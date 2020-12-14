class Clone < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :students,  presence: true
  validates :user, uniqueness: { scope: :project }

  # validates :url,       presence: true

  # before_validation :set_owner_and_repo

  private

  # def set_owner_and_repo
    # uri = URI(url)
    # self.owner, self.repo_name = uri.path.split("/")[1..-1]
  # end
end
