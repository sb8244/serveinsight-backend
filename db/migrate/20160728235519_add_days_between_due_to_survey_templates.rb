class AddDaysBetweenDueToSurveyTemplates < ActiveRecord::Migration
  def up
    add_column :survey_templates, :days_between_due, :integer

    SurveyTemplate.find_each do |template|
      template.update!(days_between_due: template.weeks_between_due / 7) if template.weeks_between_due
    end
  end

  def down
    remove_column :survey_templates, :days_between_due
  end
end
