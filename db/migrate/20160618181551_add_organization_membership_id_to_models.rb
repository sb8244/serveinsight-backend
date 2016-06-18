class AddOrganizationMembershipIdToModels < ActiveRecord::Migration
  def change
    add_column :answers, :organization_membership_id, :integer
    add_column :goals, :organization_membership_id, :integer

    Answer.find_each do |answer|
      answer.update!(organization_membership_id: answer.survey_instance.organization_membership_id)
    end

    Goal.find_each do |goal|
      goal.update!(organization_membership_id: goal.survey_instance.organization_membership_id)
    end

    change_column :answers, :organization_membership_id, :integer, null: false
    change_column :goals, :organization_membership_id, :integer, null: false
  end
end
