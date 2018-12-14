class AddGithubProjectIdToClone < ActiveRecord::Migration[5.1]
  def change
    add_column :clones, :github_project_id, :string
  end
end
