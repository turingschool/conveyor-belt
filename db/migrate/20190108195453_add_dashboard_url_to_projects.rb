class AddDashboardUrlToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :dashboard_url, :string
  end
end
