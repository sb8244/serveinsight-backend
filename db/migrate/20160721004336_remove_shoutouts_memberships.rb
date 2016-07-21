class RemoveShoutoutsMemberships < ActiveRecord::Migration
  def change
    remove_column :shoutouts, :organization_membership_id, :integer
  end
end
