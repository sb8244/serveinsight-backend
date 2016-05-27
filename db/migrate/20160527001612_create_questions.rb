class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :question, null: false
      t.belongs_to :organization, null: false, index: true
      t.belongs_to :survey_template, null: false, index: true

      t.timestamps null: false
    end
  end
end
