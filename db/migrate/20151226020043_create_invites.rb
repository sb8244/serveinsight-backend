class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.belongs_to :organization, index: true, null: false
      t.string :email, null: false
      t.boolean :admin, null: false, default: false
      t.boolean :accepted, null: false, default: false

      t.timestamps null: false
    end

    add_index :invites, [:organization_id, :email], unique: true
  end
end
