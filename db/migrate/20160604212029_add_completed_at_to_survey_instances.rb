class AddCompletedAtToSurveyInstances < ActiveRecord::Migration
  def change
    add_column :survey_instances, :completed_at, :datetime
  end
end
