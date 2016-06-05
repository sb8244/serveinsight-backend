class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.belongs_to :survey_instance, index: true, null: false
      t.belongs_to :organization, index: true, null: false
      t.text :content, null: false
      t.integer :order, null: false

      t.timestamps null: false
    end
  end
end
