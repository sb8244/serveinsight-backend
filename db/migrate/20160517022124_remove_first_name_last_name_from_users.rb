class RemoveFirstNameLastNameFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :first_name, :string, null: false
    remove_column :users, :last_name, :string, null: false
  end
end
