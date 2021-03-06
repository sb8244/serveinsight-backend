class SurveyTemplate < ActiveRecord::Base
  has_many :questions
  has_many :survey_instances
  belongs_to :organization
  belongs_to :creator, class_name: "OrganizationMembership"

  def self.due
    where("next_due_at < ?", Time.now)
  end

  def self.active
    where(completed_at: nil)
  end

  def ordered_questions
    questions.select(&:current?).sort_by(&:order)
  end

  def members_in_scope
    organization.organization_memberships
  end

  def update_instances_due!
    survey_instances.where(iteration: iteration).update_all(due_at: next_due_at)
  end

  def completed!
    update!(completed_at: Time.now)
    survey_instances.where(iteration: iteration).not_completed.delete_all
  end
end
