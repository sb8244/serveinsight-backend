class AddCompletedAtToSurveyTemplates < ActiveRecord::Migration
  def change
    add_column :survey_templates, :completed_at, :datetime
  end
end
