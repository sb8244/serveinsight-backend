class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :comment, null: false
      t.string :role, default: "comments"
      t.references :commentable, polymorphic: true, index: false, null: false
      t.references :organization_membership, index: true, null: false
      t.timestamps
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
  end

  def self.down
    drop_table :comments
  end
end
