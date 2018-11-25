class CreateClones < ActiveRecord::Migration[5.1]
  def change
    create_table :clones do |t|
      t.string :students
      t.string :owner
      t.string :repo_name
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
