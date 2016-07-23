class ChangeMissedToDate < ActiveRecord::Migration
  def up
    add_column :survey_instances, :missed_at, :datetime
    SurveyInstance.where(missed: true).update_all("missed_at = updated_at")
    remove_column :survey_instances, :missed
    add_index :survey_instances, :missed_at
  end

  def down
    add_column :survey_instances, :missed, :boolean, default: false
    SurveyInstance.where.not(missed_at: nil).update_all(missed: true)
    remove_column :survey_instances, :missed_at
    add_index :survey_instances, :missed
  end
end
