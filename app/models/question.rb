class Question < ActiveRecord::Base
  belongs_to :organization
  belongs_to :survey_template
end
