class AddNameToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :name, :string, null: false
  end
end
