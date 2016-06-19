class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :organization_membership, index: true, null: false
      t.string :notification_type, null: false
      t.json :notification_details, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps null: false
    end
  end
end
