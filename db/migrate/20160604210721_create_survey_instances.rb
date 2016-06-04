class CreateSurveyInstances < ActiveRecord::Migration
  def change
    create_table :survey_instances do |t|
      t.belongs_to :organization_membership, index: true, null: false
      t.belongs_to :survey_template, index: true, null: false
      t.integer :iteration, null: false

      t.timestamps null: false
    end
  end
end
