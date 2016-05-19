class RemoveEmailAndNameFromInvites < ActiveRecord::Migration
  def change
    remove_column :invites, :name, :string, null: false
    remove_column :invites, :email, :string, null: false
  end
end
