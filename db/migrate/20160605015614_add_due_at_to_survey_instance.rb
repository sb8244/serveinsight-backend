class AddDueAtToSurveyInstance < ActiveRecord::Migration
  def change
    add_column :survey_instances, :due_at, :datetime, null: false
  end
end
