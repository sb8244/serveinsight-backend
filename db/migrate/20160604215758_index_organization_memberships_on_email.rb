class IndexOrganizationMembershipsOnEmail < ActiveRecord::Migration
  def change
    add_index :organization_memberships, [:email, :organization_id], unique: true
  end
end
