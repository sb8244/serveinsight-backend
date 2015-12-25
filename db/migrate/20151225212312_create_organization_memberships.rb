class CreateOrganizationMemberships < ActiveRecord::Migration
  def change
    create_table :organization_memberships do |t|
      t.belongs_to :organization, index: true, null: false
      t.belongs_to :user, index: true, null: false

      t.timestamps null: false
    end

    add_index :organization_memberships, [:organization_id, :user_id], unique: true
  end
end
