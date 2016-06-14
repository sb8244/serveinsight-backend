class UpdateIndexOnMentionName < ActiveRecord::Migration
  def up
    change_column :organization_memberships, :mention_name, :string, null: false
    add_index :organization_memberships, :mention_name, unique: true
  end

  def down
    change_column :organization_memberships, :mention_name, :string, null: true
    remove_index :organization_memberships, :mention_name
  end
end
