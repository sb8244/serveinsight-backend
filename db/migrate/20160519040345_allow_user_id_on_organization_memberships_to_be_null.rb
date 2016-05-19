class AllowUserIdOnOrganizationMembershipsToBeNull < ActiveRecord::Migration
  def change
    change_column :organization_memberships, :user_id, :integer, null: true
  end
end
