class AddOrganizationToShoutouts < ActiveRecord::Migration
  def change
    add_reference :shoutouts, :organization, index: true, null: false
  end
end
