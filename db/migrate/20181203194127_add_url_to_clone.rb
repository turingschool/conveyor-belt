class AddUrlToClone < ActiveRecord::Migration[5.1]
  def change
    add_column :clones, :url, :string
  end
end
