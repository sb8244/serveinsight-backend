class AddMentionNameToOrganizationMemberships < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :mention_name, :string
  end
end
