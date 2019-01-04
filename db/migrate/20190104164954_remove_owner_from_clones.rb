class RemoveOwnerFromClones < ActiveRecord::Migration[5.1]
  def change
    remove_column :clones, :owner
  end
end
