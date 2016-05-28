class SurveyTemplate < ActiveRecord::Base
  has_many :questions
  belongs_to :organization
  belongs_to :creator, class_name: "OrganizationMembership"
end
