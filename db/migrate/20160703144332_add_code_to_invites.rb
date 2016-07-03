class AddCodeToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :code, :string, null: false
    add_index :invites, :code, unique: true
  end
end
