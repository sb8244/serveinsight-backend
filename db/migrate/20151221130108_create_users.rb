class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.text :email, null: false
      t.text :image_url

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
