class AddIterationToSurveyTemplates < ActiveRecord::Migration
  def change
    add_column :survey_templates, :iteration, :integer, default: 0, null: false
  end
end
