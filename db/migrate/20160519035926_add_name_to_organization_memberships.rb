class AddNameToOrganizationMemberships < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :name, :string, null: false
  end
end
