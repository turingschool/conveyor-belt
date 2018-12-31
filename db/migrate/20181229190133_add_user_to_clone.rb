class AddUserToClone < ActiveRecord::Migration[5.1]
  def change
    add_reference :clones, :user, foreign_key: true
  end
end
