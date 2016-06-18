class ChangePassupsToPolymorphic < ActiveRecord::Migration
  def change
    remove_index :passups, name: "unique_passup_per_answer_user"
    remove_column :passups, :answer_id, :integer, null: false
    add_column :passups, :passupable_id, :integer, null: false
    add_column :passups, :passupable_type, :string, null: false

    add_index :passups, [:passupable_id, :passupable_type, :passed_up_to_id, :passed_up_by_id], unique: true, name: "unique_passup_per_type_user"
  end
end
