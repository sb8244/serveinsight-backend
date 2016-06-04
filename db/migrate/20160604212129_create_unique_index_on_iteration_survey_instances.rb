class CreateUniqueIndexOnIterationSurveyInstances < ActiveRecord::Migration
  def change
    add_index :survey_instances, [:iteration, :organization_membership_id, :survey_template_id], unique: true, name: "survey_instances_unique_members"
  end
end
