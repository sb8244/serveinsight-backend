class AddReviewedAtToSurveyInstances < ActiveRecord::Migration
  def change
    add_column :survey_instances, :reviewed_at, :datetime
  end
end
