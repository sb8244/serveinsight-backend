class Goal < ActiveRecord::Base
  belongs_to :survey_instance
  belongs_to :organization
end
