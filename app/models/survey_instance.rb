class SurveyInstance < ActiveRecord::Base
  belongs_to :organization_membership
  belongs_to :survey_template

  has_many :answers
  has_many :goals

  def self.due
    where(completed_at: nil)
  end

  def self.completed
    where.not(completed_at: nil)
  end
end
