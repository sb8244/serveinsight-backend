class Goal < ActiveRecord::Base
  belongs_to :survey_instance
  belongs_to :organization

  validates :status, inclusion: { in: [ "complete", "miss" ] }, allow_nil: true
end
