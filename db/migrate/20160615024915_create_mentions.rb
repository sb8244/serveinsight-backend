class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :mentionable_id, null: false
      t.string :mentionable_type, null: false
      t.belongs_to :organization_membership, index: true, null: false
      t.integer :mentioned_by_id, null: false

      t.timestamps null: false
    end

    add_index :mentions, :mentioned_by_id
  end
end
