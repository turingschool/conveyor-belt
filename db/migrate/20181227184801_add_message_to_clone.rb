class AddMessageToClone < ActiveRecord::Migration[5.1]
  def change
    add_column :clones, :message, :text
  end
end
