class CreatePassups < ActiveRecord::Migration
  def change
    create_table :passups do |t|
      t.belongs_to :organization, index: true, null: false
      t.belongs_to :answer, index: true, null: false
      t.integer :passed_up_by_id, null: false
      t.integer :passed_up_to_id, null: false

      t.timestamps null: false
    end

    # A user can pass up a single answer only once to the person above them
    add_index :passups, [:answer_id, :passed_up_to_id, :passed_up_by_id], unique: true, name: "unique_passup_per_answer_user"
    add_index :passups, :passed_up_by_id
    add_index :passups, :passed_up_to_id
  end
end
