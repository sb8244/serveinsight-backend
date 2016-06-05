class AddNextDueAtToSurveyTemplates < ActiveRecord::Migration
  def change
    add_column :survey_templates, :next_due_at, :datetime, null: false
    add_column :survey_templates, :due_day, :string, null: false
    add_column :survey_templates, :due_time, :string, null: false
    add_column :survey_templates, :due_timezone, :string, null: false
    add_column :survey_templates, :weeks_between_due, :integer, null: false
  end
end
