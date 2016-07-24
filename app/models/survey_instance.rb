class SurveyInstance < ActiveRecord::Base
  belongs_to :organization_membership
  belongs_to :survey_template

  has_many :answers
  has_many :goals

  acts_as_commentable

  def self.due
    where(completed_at: nil)
  end

  def self.not_missed
    where(missed_at: nil)
  end

  def self.missed
    where.not(missed_at: nil)
  end

  def self.not_missed_within_days(days:)
    where("missed_at IS NULL OR missed_at >= ?", days.days.ago)
  end

  def self.completed
    where.not(completed_at: nil)
  end

  def missed?
    missed_at.present?
  end

  def previous_instance
    @previous_instance ||= survey_template.survey_instances.
      where(organization_membership: organization_membership).
      where("iteration < ?", iteration).
      completed.
      order(due_at: :desc).
      first
  end

  def string_questions
    survey_template.questions.order(order: :asc).pluck(:question).tap do |arr|
      if survey_template.goals_section?
        arr.unshift(Goal::GOAL_QUESTION)
      end
    end
  end

  def member_has_access?(organization_membership)
    instance_owner = self.organization_membership
    owner_or_managed = instance_owner == organization_membership || instance_owner.managed_by?(organization_membership)
    owner_or_managed
  end
end
