class AddStatusToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :status, :string, null: false, default: "miss"
  end
end
