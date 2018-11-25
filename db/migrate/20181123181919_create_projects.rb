class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.string :hash_id, index: true
      t.string :project_board_base_url

      t.timestamps
    end
  end
end
