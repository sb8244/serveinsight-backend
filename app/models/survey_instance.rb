class SurveyInstance < ActiveRecord::Base
  belongs_to :organization_membership
  belongs_to :survey_template
end
