class RemoveRepoNameFromClones < ActiveRecord::Migration[5.1]
  def change
    remove_column :clones, :repo_name
  end
end
