class SurveyInstance < ActiveRecord::Base
  belongs_to :organization_membership
  belongs_to :survey_template

  has_many :answers
  has_many :goals

  acts_as_commentable

  def self.due
    where(completed_at: nil)
  end

  def self.completed
    where.not(completed_at: nil)
  end

  def previous_instance
    @previous_instance ||= survey_template.survey_instances.
      where(organization_membership: organization_membership).
      where("iteration < ?", iteration).
      completed.
      order(due_at: :desc).
      first
  end
end
