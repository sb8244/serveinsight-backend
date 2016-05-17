class AddReviewerIdToOrganizationMemberships < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :reviewer_id, :integer
    add_index :organization_memberships, :reviewer_id
  end
end
