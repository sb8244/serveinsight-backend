class CreateShoutouts < ActiveRecord::Migration
  def change
    create_table :shoutouts do |t|
      t.belongs_to :organization_membership, index: true, null: false
      t.integer :shouted_by_id, null: false
      t.text :content, null: false

      t.timestamps null: false
    end

    add_index :shoutouts, :shouted_by_id
  end
end
