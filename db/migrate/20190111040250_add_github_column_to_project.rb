class AddGithubColumnToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :github_column, :string
  end
end
