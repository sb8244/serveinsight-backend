class RemoveColumnWeeksBetweenDueOnSurveyTemplates < ActiveRecord::Migration
  def up
    remove_column :survey_templates, :weeks_between_due
  end

  def down
    add_column :survey_templates, :weeks_between_due, :integer
    SurveyTemplate.find_each do |template|
      template.update!(weeks_between_due: template.days_between_due / 7) if template.days_between_due
    end
  end
end
