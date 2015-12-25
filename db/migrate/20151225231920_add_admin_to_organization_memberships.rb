class AddAdminToOrganizationMemberships < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :admin, :boolean, default: false
  end
end
