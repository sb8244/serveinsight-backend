class SurveyInstance < ActiveRecord::Base
  belongs_to :organization_membership
  belongs_to :survey_template

  def self.due
    where(completed_at: nil)
  end
end
