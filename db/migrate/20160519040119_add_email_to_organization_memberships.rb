class AddEmailToOrganizationMemberships < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :email, :string, null: false
  end
end
