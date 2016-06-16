class AddMissedToSurveyInstances < ActiveRecord::Migration
  def change
    add_column :survey_instances, :missed, :boolean, default: false
  end
end
