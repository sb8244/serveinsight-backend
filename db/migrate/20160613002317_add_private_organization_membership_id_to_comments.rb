class AddPrivateOrganizationMembershipIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :private_organization_membership_id, :integer
  end
end
