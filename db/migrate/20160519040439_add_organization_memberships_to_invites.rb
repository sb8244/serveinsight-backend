class AddOrganizationMembershipsToInvites < ActiveRecord::Migration
  def change
    add_reference :invites, :organization_membership, index: true, null: false
    remove_reference :invites, :organization
  end
end
