class SurveyTemplate < ActiveRecord::Base
  has_many :questions
  has_many :survey_instances
  belongs_to :organization
  belongs_to :creator, class_name: "OrganizationMembership"

  def ordered_questions
    questions.select(&:current?).sort_by(&:order)
  end
end
