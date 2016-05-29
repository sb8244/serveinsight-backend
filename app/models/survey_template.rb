class SurveyTemplate < ActiveRecord::Base
  has_many :questions
  belongs_to :organization
  belongs_to :creator, class_name: "OrganizationMembership"

  def ordered_questions
    questions.select(&:current?).sort_by(&:order)
  end
end
