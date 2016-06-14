class UpdateIndexOnMentionName < ActiveRecord::Migration
  def up
    change_column :organization_memberships, :mention_name, :string, null: false
    add_index :organization_memberships, [:mention_name, :organization_id], unique: true, name: "unique_mention_name_on_memberships"
  end

  def down
    change_column :organization_memberships, :mention_name, :string, null: true
    remove_index :organization_memberships, [:mention_name, :organization_id], name: "unique_mention_name_on_memberships"
  end
end
