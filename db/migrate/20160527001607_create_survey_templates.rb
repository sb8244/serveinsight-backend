class CreateSurveyTemplates < ActiveRecord::Migration
  def change
    create_table :survey_templates do |t|
      t.belongs_to :organization, null: false, index: true
      t.integer :creator_id, null: false
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.boolean :recurring, null: false, default: true
      t.boolean :goals_section, null: false, default: true

      t.timestamps null: false
    end
  end
end
